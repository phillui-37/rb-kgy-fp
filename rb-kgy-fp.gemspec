Gem::Specification.new do |s|
  s.name = "rb-kgy-fp"
  s.version = "1.0.2"
  s.summary = "Ruby FP lib for self usage"
  s.description = "Ruby FP lib for self usage. This lib included simple FP functions like Rmada of JS, and different typeclass support as Haskell"
  s.authors = "Phil Lui"
  s.email = "phillui37@gmail.com"
  s.files = Dir['lib/**/*.rb'].filter { |filename| File.file?(filename) && !File.read('.gitignore').split.include?(filename) }
  s.homepage = "https://github.com/phillui-37/rb-kgy-fp"
  s.license = "MIT"
  s.metadata = {
    'bug_tracker_uri' => "https://github.com/phillui-37/rb-kgy-fp/issues",
    "change_log_uri" => "https://github.com/phillui-37/rb-kgy-fp/CHANGELOG.md",
    "homepage_uri" => "https://github.com/phillui-37/rb-kgy-fp",
    "source_code_uri" => "https://github.com/phillui-37/rb-kgy-fp",
  }
end