platform :ios, '12.0'

use_modular_headers!
inhibit_all_warnings!

target 'RezolveSDKSample' do
  # Common
  pod 'JSONWebToken', :git => 'https://github.com/radianttap/JSONWebToken.swift.git'
  pod 'Kingfisher', '5.13.4'
  pod 'SwifterSwift', '5.2.0'
  
  # Corporate SDK
  pod 'RezolveSDK', '2.0.10.2-beta1595'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
    end
  end
end
