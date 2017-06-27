Pod::Spec.new do |s|
  s.name         = 'FootlessParser'
  s.version      = '0.3.1'
  s.summary      = 'A simple parser combinator written in Swift'
  s.description  = 'FootlessParser is a simple and pretty naive implementation of a parser combinator in Swift. It enables infinite lookahead, non-ambiguous parsing with error reporting.'
  s.homepage     = 'https://github.com/kareman/FootlessParser'
  s.license      = { type: 'MIT', file: 'LICENSE.txt' }
  s.author = { 'Kare Morstol' => 'kare@nottoobadsoftware.com' }
  s.source = { git: 'https://github.com/kareman/FootlessParser.git', tag: s.version.to_s }
  s.source_files = 'Sources/*.swift'
  s.osx.deployment_target = '10.10'
end
