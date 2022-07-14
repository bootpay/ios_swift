#
# Be sure to run `pod lib lint Bootpay.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Bootpay'
  s.version          = '4.3.0'
  s.summary          = 'Bootpay에서 지원하는 공식 Swift 라이브러리 입니다. ios 9 이상부터 사용가능합니다.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Bootpay에서 지원하는 공식 Swift 라이브러리 입니다. ios 9 이상부터 사용가능합니다.
                       DESC

  s.homepage         = 'https://github.com/bootpay/ios_swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'bootpay' => 'bootpay.co.kr@gmail.com' }
  s.source           = { :git => 'https://github.com/bootpay/ios_swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
#  s.osx.deployment_target = '10.12'

  s.source_files = 'Bootpay/Classes/**/*'
  
  
  s.swift_versions = ['5.0']
  
  # s.resource_bundles = {
  #   'Bootpay' => ['Bootpay/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  
  s.dependency 'CryptoSwift'
  s.dependency 'ObjectMapper'
end
