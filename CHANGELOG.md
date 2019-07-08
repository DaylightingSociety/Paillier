# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
### Added
- This CHANGELOG.md file, retroactively written to describe past versions.

## [1.2.1] - 29 June 2019
### Changes
- Updated README.md to include mention of community contributors.

### Fixed
- Deprecation warning from using BigDecimal.new.
- Unused variable warning.

## [1.2.0] - 10 November 2018
### Changes
- Changed primality test from Little Fermat to Rabin-Miller.
- Prime generation uses a default argument to determine the number of times to test, instead of relying on a class variable to determine this.

### Fixed
- Minor typo fix.

## [1.1.0] - 13 September 2017
### Added
- Additional test cases.
- Private key deserialization.

### Changes
- Documentation improvement.
- Minor implementation changes to account for deserialization.

## [1.0.0] - 18 December 2016
### Added
- Functionality to create Paillier keypairs.
- Functionality to encrypt and decrypt with Paillier keypairs.
- Functionality to sign messages using Paillier keypairs.
- Functionality to add Paillier encrypted messages together.
- Functionality to perform zero-knowledge proofs on encrypted content.
- Unit testing.
