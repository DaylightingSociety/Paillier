module Paillier
	class PrivateKey
		attr_reader :l, :m # :nodoc:

		def initialize(l,m) # :nodoc:
			@l = l
			@m = m
		end

		# Serialize a private key to string form
		#
		# Example:
		#	>> priv, pub = Paillier.generateKeypair(2048)
		#	>> priv.to_s
		#	=> "110107191408889682017277609474037601699496910..."
		#
		def to_s
			return "#{@l},#{@m}"
		end

		# De-serialize a private key string back into object form
		#
		# Example:
		#	>> s = priv.to_s
		#	>> newPriv = Paillier::PrivateKey.from_s(s)
		#	=> #<Paillier::PrivateKey>
		#
		# Arguments:
		#	string (String)
		def PrivateKey.from_s(string)
			l,m = string.split(",")
			return PrivateKey.new(l.to_i, m.to_i)
		end
	end

	class PublicKey
		attr_reader :n, :n_sq, :g # :nodoc:

		def initialize(n) # :nodoc:
			@n = n
			@n_sq = n * n
			@g = n+1
		end

		# Serialize a public key to string form
		#
		# Example:
		#	>> priv, pub = Paillier.generateKeypair(2048)
		#	>> pub.to_s
		#	=> "110107191408889682017277609474037601699496910..."
		#
		def to_s
			return "#{@n}"
		end

		# De-serialize a public key string back into object form
		#
		# Example:
		#	>> s = pub.to_s
		#	>> newPub = Paillier::PublicKey.from_s(s)
		#	=> #<Paillier::PublicKey>
		#
		# Arguments:
		#	string (String)
		def PublicKey.from_s(string)
			return PublicKey.new(string.to_i)
		end
	end
end
