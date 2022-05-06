platform :ios, '12.0'

use_modular_headers!
inhibit_all_warnings!

target 'RezolveSDKSample' do
  # Common
  pod 'JSONWebToken', :git => 'https://github.com/radianttap/JSONWebToken.swift.git'
  pod 'Kingfisher', '5.13.4'
  pod 'SwifterSwift', '5.2.0'
  
  # Corporate SDK
  pod 'RezolveSDK', '2.1.1.2-bp-beta1793'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '12.0'
      config.build_settings['SWIFT_VERSION'] = '5.3'
      config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      
      xcconfig_path = config.base_configuration_reference.real_path
      xcconfig = File.read(xcconfig_path)
      xcconfig.sub!('-framework "BMKLocationKit"', '')
      File.open(xcconfig_path, "w") { |file| file << xcconfig }
    end
  end
end
