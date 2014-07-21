$:.unshift File.expand_path('../lib', __FILE__)
require 'soapui-util/version'

Gem::Specification.new do |s|
  s.name                  = SoapuiUtil::VERSION::NAME
  s.version               = SoapuiUtil::VERSION::STRING
  s.summary               = SoapuiUtil::VERSION::SUMMARY
  s.authors               = ['kevin.c', 'cyrus']
  s.email                 = ''
  s.description           = "Provides access to SoapUI's soap message & wsdl functionality"
  s.homepage              = 'https://github.com/sandwichclub/soapui-util'
  s.license               = 'MIT'

  #s.files                 = Dir.glob("{javalib,lib}/**/*") + %w(soapui-log4j.xml)
  s.files                 = Dir["lib/**/*.rb", "javalib/**/*", "soapui-log4j.xml"]
  s.test_files            = Dir.glob('spec/*.rb')
  s.require_paths         = ['lib']

  #s.require_ruby_version('>= 1.9.3')
  s.add_dependency('rjb', '1.4.8')
  s.add_dependency('fiddle')
  s.add_development_dependency('rake', ['~>10.3.2'])
  s.add_development_dependency('rspec', ['~>2.99'])

  s.requirements << 'rjb, 1.4.8'
  s.requirements << 'fiddle'
  s.requirements << 'JAVA_HOME set in the environment variables'
  s.requirements << 'LD_LIBRARY_PATH if null, will be set to JAVA_HOME/lib'
end