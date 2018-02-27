Gem::Specification.new do |s|
  s.name        = "java_dissassembler"
  s.version     = "0.0.2"
  s.date        = "2018-02-22"
  s.summary     = "Java .class file dissassembler"
  s.description = "A Java .class file dissassembler.  Similar to javap, but w/ no JDK dependencies.  Pure Ruby"
  s.authors     = ["Josh Bodily"]
  s.email       = "joshbodily@gmail.com"
  s.files       = ["lib/java_dissassembler.rb", "lib/java_dissassembler/array.rb", "lib/java_dissassembler/method.rb", "lib/java_dissassembler/class.rb", "lib/java_dissassembler/field.rb", "lib/java_dissassembler/annotatable.rb", "lib/java_dissassembler/erb_helper.rb"]
  s.homepage    = "https://github.com/joshbodily/java_dissassembler"
  s.license      = "MIT"
  s.required_ruby_version = ">= 1.9.3"
end
