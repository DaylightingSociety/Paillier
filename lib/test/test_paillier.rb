#!/usr/bin/env ruby

=begin
	This module tests the higher-level Paillier functionality that
	users will be exposed to. Lower level tests should be conducted
	in test_primes and test_paillier_math.
=end

require_relative '../paillier'
require 'test/unit'

class TestPaillier < Test::Unit::TestCase #:nodoc:
	def setup()
		# We only need to make a keypair once, and can re-use it for all
		# the tests. To pull this off we use a module variable.
		unless( defined?(@@priv) and defined?(@@pub) )
			puts "Generating keypair..."
			(@@priv, @@pub) = Paillier.generateKeypair(2048)
		end
	end

	def testSanity()
		x = 3
		cx = Paillier.encrypt(@@pub, x)
		dx = Paillier.decrypt(@@priv, @@pub, cx)
		assert_not_equal(x, cx)
		assert_equal(x, dx)
	end

	def testSanityWithStrings()
		x = "3"
		cx = Paillier.encrypt(@@pub, x)
		dx = Paillier.decrypt(@@priv, @@pub, cx.to_s)
		assert_not_equal(x.to_i, cx)
		assert_equal(x.to_i, dx)
	end

	def testCryptoAddition()
		x = 3
		y = 5
		cx = Paillier.encrypt(@@pub, x)
		cy = Paillier.encrypt(@@pub, y)
		cz = Paillier.eAdd(@@pub, cx, cy)
		z = Paillier.decrypt(@@priv, @@pub, cz)
		assert_equal(x + y, z)
	end

	def testConstAddition()
		x = 3
		cx = Paillier.encrypt(@@pub, x)
		cy = Paillier.eAddConst(@@pub, cx, 2)
		y = Paillier.decrypt(@@priv, @@pub, cy)
		assert_equal(x + 2, y)
	end

	def testConstMultiply()
		x = 3
		cx = Paillier.encrypt(@@pub, x)
		cy = Paillier.eMulConst(@@pub, cx, 2)
		y = Paillier.decrypt(@@priv, @@pub, cy)
		assert_equal(x * 2, y)
	end

	def testValidSignature()
		sig = Paillier.sign(@@priv, @@pub, 1000)
		valid = Paillier.validSignature?(@@pub, 1000, sig)
		assert_equal(valid, true)
	end

	def testInvalidSignature()
		sig = Paillier.sign(@@priv, @@pub, 1000)
		valid = Paillier.validSignature?(@@pub, 666, sig)
		assert_equal(valid, false)
	end

	def testSignatureSerialization()
		sig = Paillier.sign(@@priv, @@pub, 1000)
		stringsig = sig.to_s
		newsig = Paillier::Signature.from_s(stringsig)
		valid = Paillier.validSignature?(@@pub, 1000, newsig)
		assert_equal(valid, true)
	end

	def testPublicKeySerialization()
		keystring = @@pub.to_s
		newPubkey = Paillier::PublicKey.from_s(keystring)
		assert_equal(@@pub.n, newPubkey.n)
	end
	
	def testPrivateKeySerialization()
		keystring = @@priv.to_s
		newPrivkey = Paillier::PrivateKey.from_s(keystring)
		assert_equal(@@priv.l, newPrivkey.l)
		assert_equal(@@priv.m, newPrivkey.m)
	end
end
