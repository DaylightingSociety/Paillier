#!/usr/bin/env ruby

require 'test/unit'
require_relative '../paillier'

class TestPaillier < Test::Unit::TestCase #:nodoc:
	def testGCD()
		assert_equal(Paillier.gcd(8, 12), 4)
		assert_equal(Paillier.gcd(54, 24), 6)
		assert_equal(Paillier.gcd(42, 56), 14)
		assert_equal(Paillier.gcd(9, 28), 1)
		assert_equal(Paillier.gcd(270, 192), 6)
	end

	def testModInv()
		assert_equal(Paillier.modInv(3, 7), 5)
		assert_equal(Paillier.modInv(3, 11), 4)
	end

	def testImpossibleModInv()
		assert_raise(ArgumentError) { Paillier.modInv(2, 6) }
	end

	def testModPow()
		assert_equal(Paillier.modPow(7, 2, 20), 9)
	end
end
