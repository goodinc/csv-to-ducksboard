Gem::Specification.new do |s|
  s.name = "csv-to-ducksboard"
  s.version = '0.1.0'
  s.has_rdoc = false
  s.bindir = '.'
  s.executables << 'csv-to-ducksboard'
  s.required_ruby_version = ">= 1.8.7"
  s.platform = Gem::Platform::RUBY
  s.files = ["csv-to-ducksboard"]
  s.required_rubygems_version = ">= 1.3.7"
  s.author = "Craig Ogg (from a fork on github)"
  s.email = %q{craig@goodinc.com}
  s.summary = %q{Easily send csv files to ducksboard}
  s.homepage = %q{https://github.com/goodinc/csv-to-ducksboard}
  s.add_dependency 'bundler'
end
