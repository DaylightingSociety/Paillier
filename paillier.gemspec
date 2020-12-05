Gem::Specification.new do |s|
	s.name        = 'paillier'
	s.version     = '1.2.3'
	s.date        = '2018-11-10'
	s.summary     = "Paillier Homomorphic Cryptosystem"
	s.description = "An implementation of Paillier homomorphic addition public key system"
	s.authors     = ["Daylighting Society"]
	s.email       = 'paillier@daylightingsociety.org'
	s.files       = ["lib/paillier.rb", "lib/paillier/keys.rb", "lib/paillier/primes.rb", "lib/paillier/signatures.rb", "lib/paillier/zkp.rb"]
	s.homepage    = 'https://paillier.daylightingsociety.org'
	s.license     = 'LGPL-3.0'
end
