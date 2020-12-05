require 'rake/testtask'
require 'rubygems/package_task'

spec = Gem::Specification.load('paillier.gemspec')
v = spec.version
Gem::PackageTask.new(spec) {}

Rake::TestTask.new do |t|
	t.libs << 'test'
	t.test_files = FileList['lib/test/test_*.rb']
	t.verbose = true
end

desc "Run tests"
task :default => :test

task :prerelease => :test

task :release => :prerelease do
    # Package up the library
    Rake::Task["package"].invoke
    # Push to rubygems
    sh "gem push pkg/paillier-#{v}.gem"
end
