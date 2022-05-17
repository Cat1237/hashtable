require File.expand_path('lib/hashtable/version', __dir__)

Gem::Specification.new do |spec|
  spec.name          = 'hashtable'
  spec.version       = Hashtable::VERSION
  spec.authors       = ['Cat1237']
  spec.email         = ['wangson1237@outlook.com']

  spec.summary       = 'This provides a hash table data structure that is specialized for handling key/value pairs.'
  spec.description   = 'This does some funky memory allocation and hashing things to make it extremely efficient, storing the key/value with `SparseBitArray`'
  spec.homepage      = 'https://github.com/Cat1237/hashtable.git'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.6'
  spec.files         = %w[README.md LICENSE] + Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '>= 2.1'
  spec.add_development_dependency 'rake', '>= 10.0'
  spec.add_development_dependency 'rspec', '>= 3.0'
end
