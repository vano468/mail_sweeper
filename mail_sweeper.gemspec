$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "mail_sweeper/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mail_sweeper"
  s.version     = MailSweeper::VERSION
  s.authors     = ["vad4msiu"]
  s.email       = ["vad4msiu@gmail.com"]
  s.homepage    = "https://github.com/vad4msiu/mail_sweeper"
  s.summary     = "Clean up your email list from bad contacts"
  s.description = "Clean up your email list from bad contacts"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5.0"
  s.add_dependency "httparty"
  s.add_dependency "protected_attributes_continued"

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", "~> 3.4"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "pry"
  s.add_development_dependency "webmock"
end
