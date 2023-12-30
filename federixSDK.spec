# my_gem.gemspec

Gem::Specification.new do |spec|
    spec.name          = 'federixSDK'
    spec.version       = '0.1.0'
    spec.authors       = ['Erick Garcia']
    spec.summary       = 'Rate your fedex service'
    spec.description   = 'Rate your service'
    spec.email         = 'erickutngarcia@gmail.com'
    spec.files         = Dir['lib/**/*.rb']  # Archivos de código fuente
    spec.required_ruby_version = '>= 2.4.0'

    # Dependencias
    spec.add_dependency 'nokogiri'
    spec.add_dependency 'net/http'
    spec.add_dependency 'uri'

    # Dependencias de desarrollo
    #spec.add_development_dependency 'rspec'
end