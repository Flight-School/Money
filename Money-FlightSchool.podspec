Pod::Spec.new do |s|
  s.name = 'Money-FlightSchool'
  s.module_name  = 'Money'
  s.version      = '1.2.0'
  s.summary      = 'A precise, type-safe representation of monetary amounts in a given currency.'

  s.description  = <<-DESC
    This functionality is discussed in Chapter 3 of
    Flight School Guide to Swift Numbers.
  DESC

  s.homepage     = 'https://flight.school/books/numbers/'

  s.license      = { type: 'MIT', file: 'LICENSE.md' }

  s.author = { 'Mattt' => 'mattt@flight.school' }

  s.social_media_url   = 'https://twitter.com/mattt'

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '2.0'
  s.tvos.deployment_target = '9.0'

  s.source = { git: 'https://github.com/Flight-School/Money.git', tag: s.version.to_s }

  s.source_files = 'Sources/**/*.swift'

  s.swift_versions = ['4.2', '5.0', '5.1', '5.2', '5.3']
  s.static_framework = true
end
