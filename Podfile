# Uncomment the next line to define a global platform for your project
platform :ios, '16.0'

target 'QuickPersonalFinance' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for QuickPersonalFinance
  pod 'FirebaseCrashlytics'
  pod 'FirebasePerformance'
  pod 'SwiftLint'
  pod 'ArkanaKeys', path: 'ArkanaKeys/ArkanaKeys'
  pod 'ArkanaKeysInterfaces', path: 'ArkanaKeys/ArkanaKeysInterfaces'

  target 'QuickPersonalFinanceTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'QuickPersonalFinanceUITests' do
    # Pods for testing
  end

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        if Gem::Version.new('11.0') > Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
        end
      end
    end
  end
end
