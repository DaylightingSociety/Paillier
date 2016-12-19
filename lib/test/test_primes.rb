#!/usr/bin/env ruby

require_relative '../paillier'
require 'test/unit'

class TestPrimes < Test::Unit::TestCase #:nodoc:

	def testIsProbablyPrime
		known_primes = [15484279, 32451217, 86027297, 179424097, 982451653, 2038072919, 18125114801, 22801762469]
		for p in known_primes
			assert_equal(Paillier::Primes.isProbablyPrime?(p), true)
		end
	end

	def testNotPrime
		known_composites = [15484281, 32451219, 179424099, 982451655, 2038072922, 18125114811, 22801762471]
		for p in known_composites
			assert_equal(Paillier::Primes.isProbablyPrime?(p), false)
		end
	end

	def testIsCoprime
		assert_equal(Paillier::Primes.isCoprime?(12, 19), true)
		assert_equal(Paillier::Primes.isCoprime?(12, 11), true)
		assert_equal(Paillier::Primes.isCoprime?(28, 29), true)
		assert_equal(Paillier::Primes.isCoprime?(28, 15), true)
	end

	def testIsNotCoprime
		assert_equal(Paillier::Primes.isCoprime?(12, 6), false)
		assert_equal(Paillier::Primes.isCoprime?(21, 7), false)
		assert_equal(Paillier::Primes.isCoprime?(28, 14), false)
		assert_equal(Paillier::Primes.isCoprime?(28, 12), false)
	end

end
