# Paillier Cryptosystem

[![Gem Version](https://badge.fury.io/rb/paillier.svg)](https://badge.fury.io/rb/paillier)

The Paillier cryptosystem, initially described in a 1999 paper by Pascal Paillier, is a public-key cryptosystem designed around additive homomorphic encryption. What this means is that any two ciphertexts can be added together, and the decryption of the result will return the sum of the plaintexts. This allows for computational offloading of work, even if the data is sensitive and must remain encrypted. 

In addition to implementing this cryptosystem, we have also implemented a zero-knowledge content proof that takes advantage of the encryption scheme in order to determine whether a given ciphertext is an encryption of a valid message, without revealing which of the possible valid messages the ciphertext is an encryption is. An example use-case for this is e-voting, where there are a limited number of possible ballots (plaintexts), and the party that is counting the votes wants to ensure that the voters are not trying to cheat or break the system.

For more details about the cryptosystem or our implementation, please visit: https://www.paillier.daylightingsociety.org

**WARNING: This code has not been validated by any cryptographers, but implements a crytosystem which has. Use at your own risk, it may be insecure.**

## License

This system is released under the GNU Lesser Public License version 3, included in the 'LICENSE' file.

## Attribution

This Paillier cryptosystem is a [Daylighting Society](https://daylightingsociety.org) project. Initial version written by Taylor Dahlin and Milo Trujillo, with contributions from Courtney Tambling. This library was inspired by Mike Ivanov's [Paillier](https://github.com/mikeivanov/paillier) library in Python, and began as a language port of that project before being largely rewritten and expanded upon.
