#
# Be sure to run `pod lib lint NetworkDetector.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'NetworkDetector'
  s.version          = '0.1.0'
  s.summary          = 'A simple Swift class that detects network changes'
  s.description      = 'This CocoaPod detects network changes and calls a closure based on the network status.'

  s.homepage         = 'https://github.com/zarzonis/NetworkDetector'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Spyros Zarzonis' => 'spyroszarzonis@gmail.com' }
  s.source           = { :git => 'https://github.com/zarzonis/NetworkDetector.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/zarzonis'
  s.swift_version = '4.2'

  s.ios.deployment_target = '12.0'

  s.source_files = 'NetworkDetector/**/*.swift'
  
  s.framework    = 'Network'
end
