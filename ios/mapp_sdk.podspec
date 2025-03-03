#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint mapp_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'mapp_sdk'
  s.version          = '0.0.9'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://mapp.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Mapp Digital' => 'stefan.stevanovic@mapp.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.dependency 'MappSDK', '6.0.8'
  s.dependency 'MappSDKInapp', '6.0.6.10'
  s.dependency 'MappSDKGeotargeting', '6.0.5'
  s.platform = :ios, '10.0'
  s.static_framework = true
  s.swift_version = '5.0'


  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'}
end
