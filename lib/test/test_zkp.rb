#!/usr/bin/env ruby

require_relative '../paillier'
require_relative '../paillier/zkp'
require 'test/unit'

class TestZKP < Test::Unit::TestCase #:nodoc:

	def testZKP 
		# generate a 2048-bit keypair
		_, pubkey = Paillier.generateKeypair(2048)

		# array of valid messages
		valid_ms = [1, 2, 3, 4, 5]
		invalid_ms = [1, 2, 3, 5, 6]

		# valid message and its encryption
		my_m = 4

		# invalid message and its encryption
		invalid_m = 7

		# create ZKP objects
		my_ZKP = Paillier::ZKP.new(pubkey, my_m, valid_ms)
		e_my_m = my_ZKP.ciphertext

		# cannot create a ZKP object with an invalid message
		assert_raise(ArgumentError) {Paillier::ZKP.new(pubkey, invalid_m, valid_ms)}

		# if the set of acceptable messages includes our message, this should return true
		assert_equal(Paillier::ZKP.verifyZKP?(pubkey, e_my_m, valid_ms, my_ZKP.commitment), true)
		# if the set of acceptable messages does not include the message, this should return false
		assert_equal(Paillier::ZKP.verifyZKP?(pubkey, e_my_m, invalid_ms, my_ZKP.commitment), false)
	end

	def testSerialization 
		_, pubkey = Paillier.generateKeypair(2048)
		valid_ms = [1,2,3,4,5]
		my_m = 4
		my_ZKP = Paillier::ZKP.new(pubkey, my_m, valid_ms)

		commitment_string = my_ZKP.commitment.to_s
		copy_ZKP = Paillier::ZKP::ZKPCommit.from_s(commitment_string)
		assert_equal(my_ZKP.commitment, copy_ZKP)
	end

end
