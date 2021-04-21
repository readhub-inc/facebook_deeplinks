#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint facebook_deeplinks.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'facebook_deeplinks'
  s.version          = '0.1.0'
  s.summary          = 'A flutter plugin to get facebook deeplinks and transferring them to the flutter application.'
  s.description      = <<-DESC
A flutter plugin to get facebook deeplinks and transferring them to the flutter application.
                       DESC
  s.homepage         = 'https://github.com/rbcprolabs/facebook_deeplinks'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Ramil Zaynetdinov' => 'me@proteye.ru' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'FBSDKCoreKit', '~> 8.2.0'
  s.swift_version = '5.0'

  s.ios.deployment_target = '9.0'
end
