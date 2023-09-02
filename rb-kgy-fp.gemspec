require 'rake/file_list'

Gem::Specification.new do |s|
  s.name        = "rb-kgy-fp"
  s.version     = "1.0.0"
  s.summary     = "Ruby FP lib for self usage"
  s.description = "Ruby FP lib for self usage. This lib included simple FP functions like Rmada of JS, and different typeclass support as Haskell"
  s.authors     = "Phil Lui"
  s.email       = "phillui37@gmail.com"
  s.files       = Rake::FileList['lib/**/*.rb'].exclude(*File.read('.gitignore').split)
  s.homepage    = "https://github.com/phillui-37/rb-kgy-fp"
  s.license     = "MIT"
end