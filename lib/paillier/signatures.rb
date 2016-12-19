module Paillier
	class Signature
		attr_reader :s1, :s2 # :nodoc:

		def initialize(s1, s2) # :nodoc:
			@s1 = s1.to_i
			@s2 = s2.to_i
		end

		# Serialize a signature to string form
		#
		# Example:
		#	>> sig = Paillier.sign(priv, pub, 3)
		#	>> sig.to_s
		#	=> "127609169397718360449546194929999128..."
		def to_s()
			return "#{s1},#{s2}"
		end

		# De-serialize a signature string to object form
		#
		# Example:
		#	>> s = sig.to_s
		#	>> newSig = Paillier::Signature.from_s(s)
		#	=> #<Paillier::Signature>
		#
		# Arguments:
		#	string (String)
		def Signature.from_s(string)
			(s1, s2) = string.split(",")
			return Signature.new(s1, s2)
		end
	end
end
