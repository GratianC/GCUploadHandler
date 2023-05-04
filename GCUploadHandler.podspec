#
# Be sure to run `pod lib lint GCUploadHandler.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'GCUploadHandler'
  s.version          = '0.1.0'
  s.summary          = 'A short description of GCUploadHandler.'
  
  # This description is used to generate tags and improve search results.
  #   * Think: What does it do? Why did you write it? What is the focus?
  #   * Try to keep it short, snappy and to the point.
  #   * Write the description between the DESC delimiters below.
  #   * Finally, don't worry about the indent, CocoaPods strips it!
  
  s.description      = <<-DESC
  TODO: Add long description of the pod here.
  DESC
  
  s.homepage         = 'https://github.com/GratianC/GCUploadHandler'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GratianChen' => '1599625137@qq.com' }
  s.source           = { :git => 'git@github.com:GratianC/GCUploadHandler.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '12.0'
  s.swift_version = '5.0'
  
  s.source_files = 'GCUploadHandler/Classes/**/*'
  
  #AWSS3
  s.subspec 'AWSS3Handler' do |ss|
    ss.source_files = 'GCUploadHandler/Classes/AWSS3Handler/*'
  end
  
  #AliOSS
  s.subspec 'AliOSSHandler' do |ss|
    ss.source_files = 'GCUploadHandler/Classes/AliOSSHandler/*'
    #AliyunOSSiOS
    ss.dependency 'AliyunOSSiOS', '~> 2.10.10'
  end
  
end
