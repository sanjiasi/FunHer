# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'FunHer' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for FunHer
  pod 'AFNetworking', '~> 4.0.1'
  pod 'YYModel', '~> 1.0.4'
  pod 'Masonry', '~> 1.1.0'
  pod 'Realm', '~> 10.29.0'#数据库
  pod 'MJRefresh', '~> 3.7.5'#拉下刷新组件  https://www.yii666.com/blog/143543.html

  target 'FunHerTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'FunHerUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end

# pod 'SVProgressHUD', '~> 2.2.5'
# pod 'MJRefresh', '~> 3.7.5'
# pod 'SDWebImage', '~>5.0'
# pod 'GoogleSignIn', '~> 6.2.4' #google登录 '~> 6.2.4'
# pod 'Google-Mobile-Ads-SDK', '~> 9.10.0' #google广告

  # Firebase
# pod 'Firebase/Analytics', '~> 9.6.0' #分析
# pod 'Firebase/Crashlytics', '~> 9.6.0' #崩溃收集
# pod 'Firebase/Auth', '~> 9.6.0' #账号权限
# pod 'Firebase/Database', '~> 9.6.0' #实时数据库
# pod 'Firebase/Messaging', '~> 9.6.0'
# pod 'Firebase/InAppMessaging', '~> 9.6.0'#, '~> 9.6.0-beta'
