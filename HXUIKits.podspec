Pod::Spec.new do |s|
  s.name             = 'HXUIKits'
  s.version          = '0.0.7'
  s.summary          = 'Common UI controls'

  s.homepage         = 'https://github.com/yiyucanglang'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'dahuanxiong' => 'xinlixuezyj@163.com' }
  s.source           = { :git => 'https://github.com/yiyucanglang/HXUIKits.git', :tag => s.version.to_s }
  s.static_framework = true

  s.ios.deployment_target = '8.0'

  s.default_subspecs = 'HXRespondAreaExpandButton', 'HXTimerButton', 'HXWebView', 'HXArrowAutoTipView'

  s.subspec 'HXRespondAreaExpandButton' do |ss|
    ss.public_header_files = 'HXRespondAreaExpandButton/*{h}'
    ss.source_files = 'HXRespondAreaExpandButton/*.{h,m}'
  end

  s.subspec 'HXTimerButton' do |ss|
    ss.public_header_files = 'HXTimerButton/*{h}'
    ss.source_files = 'HXTimerButton/*.{h,m}'
    ss.dependency 'Masonry'
  end

  s.subspec 'HXWebView' do |ss|
    ss.public_header_files = 'HXWebView/*{h}'
    ss.source_files = 'HXWebView/*.{h,m}'
    ss.dependency 'KVOController'
    ss.dependency 'Masonry'
  end

  s.subspec 'HXCommonShareView' do |ss|
    ss.public_header_files = 'HXCommonShareView/*{h}'
    ss.source_files = 'HXCommonShareView/*.{h,m}'
    ss.resource = "HXCommonShareView/HXShareResources.bundle"
    ss.dependency 'Masonry'
    ss.dependency 'HXKitComponent/HXImgtextCombineView'
  end

  s.subspec 'HXArrowAutoTipView' do |ss|
    ss.public_header_files = 'HXArrowAutoTipView/*{h}'
    ss.source_files = 'HXArrowAutoTipView/*.{h,m}'
    ss.dependency 'Masonry'
  end
  
  s.subspec 'HXSegmentView' do |ss|
    ss.public_header_files = 'HXSegmentView/*{h}'
    ss.source_files = 'HXSegmentView/*.{h,m}'
    ss.dependency 'HXConvenientListView/Core'
  end


  
 end
