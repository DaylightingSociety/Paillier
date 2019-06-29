require 'openssl'
require 'securerandom'

module Paillier
	module Primes # :nodoc:

		SmallPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

		def self.bitLength(int)
			return int.to_s(2).length
		end

        # This is an implementation of the Rabin-Miller primality test.
        # Previous versions used Little Fermat, but that is not effective
        # in all cases; specifically, it can be thwarted by Carmichael 
        # numbers. We use 50 rounds as the default, in order to get a certainty
        # of 2^-100 that we have found a prime. This implementation is adapted
        # from https://rosettacode.org/wiki/Miller-Rabin_primality_test#Ruby
        def self.probabilisticPrimeTest(target, k=50)
            d = target-1
            s = 0
            while d % 2 == 0
                d /= 2
                s += 1
            end
            k.times do
                a = 2 + rand(target-4)
                x = a.to_bn.mod_exp(d, target)
                next if x == 1 || x == target-1
                (s - 1).times do
                    x = x.to_bn.mod_exp(2, target)
                    return false if x == 1
                    break if x == target - 1
                end
                return false if x != target-1
            end
            return true # probs prime
        end

		def self.isProbablyPrime?(possible, k=50)
			if( possible == 1 )
				return true
			end
			for i in SmallPrimes
				if( possible == i )
					return true
				elsif( possible % i == 0 )
					return false
				end
			end
			# This isn't a known prime number, so we'll check for primality
			# probabilistically
			return probabilisticPrimeTest(possible, k)
		end

		# Expensive test to prove coprimality.
		# If GCD == 1, the numbers are coprime
		def self.isCoprime?(p, q)
			while(q > 0)
				p, q = q, p % q
			end
			return (p == 1)
		end

		# Get a random prime of appropriate length
		def self.generatePrime(bits, k=50)
			if( bits < 8 )
				raise "Bits less than eight!"
			end
			while( true )
				lowerBound = (2 ** (bits-1) + 1)
				size = ((2 ** bits) - lowerBound)
				possible = (lowerBound + SecureRandom.random_number(size)) | 1
				if isProbablyPrime?(possible, k)
					return possible
				end
			end
		end

		def self.generateCoprime(bits, coprime_to)
			if( bits < 8 )
				raise "Bits less than eight!"
			end

			# If we find a number not coprime to n then finding `p` and `q` is trivial.
			# This will almost never happen for keys of reasonable size, so if
			# `coprime_to` is big enough we won't bother running the expensive test.
			no_test_needed = false
			if( coprime_to > (2 ** 1024) )
				no_test_needed = true
			end

			while( true )
				lowerBound = (2 ** (bits-1) + 1)
				size = ((2 ** bits) - lowerBound)
				possible = (lowerBound + SecureRandom.random_number(size)) | 1
				if no_test_needed or isCoprime?(possible, coprime_to)
					return possible
				end
			end
		end
	end
end
