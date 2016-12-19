module Paillier
	class PrivateKey
		attr_reader :l, :m # :nodoc:

		def initialize(l,m) # :nodoc:
			@l = l
			@m = m
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
