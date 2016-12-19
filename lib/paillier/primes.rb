require 'openssl'
require 'securerandom'

module Paillier
	module Primes # :nodoc:

		SmallPrimes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]

		def self.bitLength(int)
			return int.to_s(2).length
		end

		def self.defaultK(bits)
			double = bits * 2
			return (40 > double) ? 40 : double
		end

		# This is based on the Wikipedia article on the Fermat primality test
		# returns true if probably prime, false if definitely composite
		def self.probabilisticPrimeTest(target, k)
			for _ in (1 .. k)
				a = rand(2 .. (target-2))
				# We want to run "x = (a ** target-1) % target", but the values
				# are huge. Instead we call out to openssl and do it with mod_exp
				mod = a.to_bn.mod_exp(target-1, target)
				if( mod != 1 )
					return false # Def composite
				end
			end
			return true # probs prime
		end

		def self.isProbablyPrime?(possible, k=nil)
			if( possible == 1 )
				return true
			end
			if( k.nil? )
				k = defaultK(bitLength(possible))
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
		def self.generatePrime(bits, k=nil)
			if( bits < 8 )
				raise "Bits less than eight!"
			end
			if( k == nil )
				k = defaultK(bits)
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

			# If we find a number not coprome to n then finding `p` and `q` is trivial.
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
