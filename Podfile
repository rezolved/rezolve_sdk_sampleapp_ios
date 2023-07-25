platform :ios, '13.0'

use_modular_headers!
inhibit_all_warnings!

target 'RezolveSDKSample' do
  # Common
  pod 'JSONWebToken', :git => 'https://github.com/radianttap/JSONWebToken.swift.git'
  pod 'Kingfisher', '5.13.4'
  pod 'SwifterSwift', '5.2.0'
  pod 'XCDYouTubeKit-kbexdev', '2.16.0'
  
  # Corporate SDK
  #pod 'RezolveSDK', '2.2.3-202306271445'
  pod 'RezolveSDK', :path => '../rezolve_sdk_ios/RezolveSDK.podspec'
  pod 'RezolveSDKToolchain', :git => 'https://github.com/rezolved/rezolve_ios_toolchain.git'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['SWIFT_VERSION'] = '5.3'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
    end
  end
end
