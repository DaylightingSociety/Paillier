#!/usr/bin/env ruby

require 'openssl'
require 'digest'
require 'bigdecimal'
require 'bigdecimal/math' # For 'log'

require_relative 'paillier/primes'
require_relative 'paillier/keys'
require_relative 'paillier/signatures'

module Paillier

	def self.gcd(u,v) # :nodoc:
		while(v > 0)
			u, v = v, u % v
		end
		return u
	end

	def self.extendedGcd(a, b) # :nodoc:
		# Make sure we're always using Bignums instead of ints
		# The behavior of the division operator is very different for bignums,
		# so it's important to use a consistent data type.
		a = a.to_bn
		b = b.to_bn
		# Can't use .abs with bignums, implemented it manually
		last_remainder = (a > 0) ? a : (-1 * a)
		remainder = (b > 0) ? b : (-1 * b)
		x, last_x, y, last_y = 0, 1, 1, 0
		while( remainder != 0 )
			t_last_remainder = remainder
			quotient, remainder = last_remainder / remainder
			last_remainder = t_last_remainder
			x, last_x = last_x - quotient*x, x
			y, last_y = last_y - quotient*y, y
		end

		return last_remainder, last_x * (a < 0 ? -1 : 1)
	end

	# Multiplicative inverse of 'a' mod 'p'
	# Returns 'b' such that a * b == 1 mod p
	def self.modInv(a, p) # :nodoc:
		if a == 0
			raise ArgumentError, "0 has no inverse mod #{p}"
		end
		(g, x) = extendedGcd(a, p)
		if( g != 1 )
			raise ArgumentError, "#{a} has no inverse mod #{p}"
		end
		return x % p
	end 

	# Returns modular exponent
	# (base ** exponent) % modulus
	# Handles very big numbers
	def self.modPow(base, exponent, modulus) # :nodoc:
		return base.to_bn.mod_exp(exponent, modulus)
	end

	# Generates a new public private keypair
	#
	# Example:
	#	>> Paillier.generateKeypair(2048)
	#	=> [#<Paillier::PrivateKey>, #<Paillier::PublicKey>]
	#
	# Arguments:
	#	bits: (Int)
	def self.generateKeypair(bits)
		p = Primes.generatePrime(bits/2)
		q = Primes.generatePrime(bits/2)
		n = p * q

		# actual keygen grumble grumble
		# all the libraries we found did it wrong and just made lambda = phi(n)
		# and set mu to phi(n)^-1
		# this is the actual spec for it
		lambda_n = ( (p-1) * (q-1) ) / gcd( (p-1), (q-1) )

		# this is technically a shortcut but not incorrect, the public key is unrelated to the private one
		g = n + 1

		# intermediary step
		u = (g.to_bn.mod_exp(lambda_n, n * n)).to_i
		# intermediary step
		u_2 = (u - 1) / n
		# now we have mu
		mu = Paillier.modInv(u_2, n)
		
		return PrivateKey.new(lambda_n, mu), PublicKey.new(n)
	end

	# For a Zero-Knowledge Proofs we need to demonstrate that we know 'r',
	# therefore 'r' must be returned.
	def self.rEncrypt(pub, plain) # :nodoc:
		r = -1
		while( true )
			# We have to use BigMath here to make sure 'log' doesn't round
			# to infinity and throw an exception
			big_n = BigDecimal(pub.n)
			r = Primes.generateCoprime(BigMath.log(big_n, 2).round, pub.n)
			if( r > 0 and r < pub.n )
				break
			end
		end
		# We want to run: x = ((r ** pub.n) % pub.n_sq)
		# But the numbers are too big, so we'll use openssl
		x = r.to_bn.mod_exp(pub.n, pub.n_sq)
		# We want to run: cipher = (((g ** plain) % pub.n_sq) * x) % pub.n_sq
		# But similarly the math is real slow and we'll use openssl
		cipher = (pub.g.to_bn.mod_exp(plain, pub.n_sq)).mod_mul(x, pub.n_sq)
		return r, cipher
	end

	# Encrypts a message with the provided public key
	#
	# Example:
	#	>> Paillier.encrypt(publicKey, 3)
	#	=> #<OpenSSL::BN:cyphertext>
	#
	# Arguments:
	#	publicKey: (Paillier::PublicKey)
	#	plaintext: (Int, OpenSSL::BN, String)
	def self.encrypt(publicKey, plaintext)
		if( plaintext.is_a?(String) )
			plaintext = OpenSSL::BN.new(plaintext)
		end
		return rEncrypt(publicKey, plaintext)[1]
	end

	# Adds one encrypted int to another
	#
	# Example:
	#	>> Paillier.eAdd(publicKey, cx, cy)
	#	=> #<OpenSSL::BN::cyphertext>
	#
	# Arguments:
	#	publicKey: (Paillier::PublicKey)
	#	a: (Int, OpenSSL::BN, String)
	#	b: (Int, OpenSSL::BN, String)
	def self.eAdd(publicKey, a, b)
		if( a.is_a?(String) )
			a = OpenSSL::BN.new(a)
		end
		if( b.is_a?(String) )
			b = OpenSSL::BN.new(b)
		end
		return a.to_bn.mod_mul(b, publicKey.n_sq)
	end

	# Adds a plaintext constant 'n' to an encrypted int
	#
	# Example:
	#	>> Paillier.eAddConst(publicKey, cyphertext, 3)
	#	=> #<OpenSSL::BN::cyphertext>
	#
	# Arguments:
	#	publicKey: (Paillier::PublicKey)
	#	a: (Int, OpenSSL::BN, String)
	#	n: (Int, OpenSSL::BN, String)
	def self.eAddConst(publicKey, a, n)
		if( a.is_a?(String) )
			a = OpenSSL::BN.new(a)
		end
		if( n.is_a?(String) )
			n = OpenSSL::BN.new(n)
		end
		return a.to_bn.mod_mul(modPow(publicKey.g, n, publicKey.n_sq), publicKey.n_sq)
	end

	# Multiplies an encrypted int by a constant
	#
	# Example:
	#	>> Paillier.eMulConst(publicKey, cyphertext, 2)
	#	=> #<OpenSSL::BN::cyphertext>
	#
	# Arguments:
	#	publicKey: (Paillier::PublicKey)
	#	a: (Int, OpenSSL::BN, String)
	#	n: (Int, OpenSSL::BN, String)
	def self.eMulConst(publicKey, a, n)
		if( a.is_a?(String) )
			a = OpenSSL::BN.new(a)
		end
		if( n.is_a?(String) )
			n = OpenSSL::BN.new(n)
		end
		return modPow(a, n, publicKey.n_sq)
	end

	# Decrypts a message, returning plaintext
	#
	# Example:
	#	>> Paillier.decrypt(priv, pub, Paillier.encrypt(priv, pub, 3))
	#	=> 3
	#
	# Arguments:
	#	privKey: (Paillier::PrivateKey)
	#	pubKey: (Paillier::PublicKey)
	#	ciphertext: (Int, OpenSSL::BN, String)
	def self.decrypt(privKey, pubKey, ciphertext)
		if( ciphertext.is_a?(String) )
			ciphertext = OpenSSL::BN.new(ciphertext)
		end
		# We want to run: x = ((cipher ** priv.l) % pub.n_sq) - 1
		# But the numbers are too big, so we'll use openssl
		x = ciphertext.to_bn.mod_exp(privKey.l, pubKey.n_sq) - 1
		plain = (x.to_i / pubKey.n.to_i).to_bn.mod_mul(privKey.m, pubKey.n)
		return plain
	end

	# Returns a detached signature for any message
	#
	# Example:
	#	>> Paillier.sign(priv, pub, 3)
	#	=> #<Paillier::Signature>
	#
	# Arguments:
	#	priv: (Paillier::PrivateKey)
	#	pub: (Paillier::PublicKey)
	#	data: (Int, OpenSSL::BN, String)
	def self.sign(priv, pub, data)
		if( data.is_a?(String) )
			data = OpenSSL::BN.new(data)
		end
		hashData = hash(data)
		# L(u) = (u-1)/n
		numerators1 = ((hashData.to_bn.mod_exp(priv.l, pub.n_sq) - 1) / pub.n.to_bn)[0]
		denominators1 = ((pub.g.to_bn.mod_exp(priv.l, pub.n_sq) - 1) / pub.n.to_bn)[0]
		#s1 = ((numerators1[0] / denominators1[0]))[0] % pub.n
		inverse_denom = Paillier.modInv(denominators1.to_i, pub.n)
		s1 = numerators1.to_bn.mod_mul(inverse_denom, pub.n)
		
		inverse_n = Paillier.modInv(pub.n, priv.l)
		inverse_g = Paillier.modInv(pub.g.to_bn.mod_exp(s1.to_bn, pub.n).to_i, pub.n)
		s2 = (hashData * inverse_g).to_bn.mod_exp(inverse_n, pub.n)

		return Signature.new(s1, s2)
	end

	def self.hash(message) # :nodoc:
		return Digest::SHA256.hexdigest(message.to_s).to_i(16)
	end

	# Validates the signature for a given message
	# Returns true if signature is good, false otherwise
	#
	# Example:
	#	>> Paillier.validSignature(pub, 3, Paillier.sign(priv, pub, 3))
	#	=> true
	#
	# Arguments:
	#	pub: (Paillier::PublicKey)
	#	message: (Int, OpenSSL::BN, String)
	#	sig: (Paillier::Signature)
	def self.validSignature?(pub, message, sig)
		if( message.is_a?(String) )
			message = OpenSSL::BN.new(message)
		end
		hash = Digest::SHA256.hexdigest(message.to_s).to_i(16)
		# We want to run (g ** s1) * (s2 ** n) % (n**2)
		# But all those numbers are huge, so we approach it in stages
		a = pub.g.to_bn.mod_exp(sig.s1, pub.n_sq)
		b = sig.s2.to_bn.mod_exp(pub.n, pub.n_sq)
		sighash = a.mod_mul(b, pub.n_sq)
		return (hash == sighash)
	end

end
