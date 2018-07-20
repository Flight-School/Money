Pod::Spec.new do |s|

  s.name         = 'Money'
  s.version      = '1.0.0'
  s.summary      = 'Type-safe representation of a monetary amount in a given currency'

  s.description  = <<-DESC
A precise, type-safe representation of a monetary amount in a given currency.
                   DESC

  s.homepage     = 'https://gumroad.com/l/swift-numbers'
  s.license      = { :type => 'MIT', :file => 'LICENSE.md' }


  s.author             = 'Mattt'
  s.social_media_url   = 'http://twitter.com/mattt'

  s.swift_version = '4.0'
  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.10'
  s.watchos.deployment_target = '3.0'
  s.tvos.deployment_target = '9.0'

  s.source       = { :git => 'https://github.com/Flight-School/Money.git', :tag => s.version.to_s }

  s.source_files  = 'Sources/Money/*.swift'

end
