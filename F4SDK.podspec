Pod::Spec.new do |spec|
  spec.name         = 'F4SDK'
  spec.platform     = :ios, '7.0'
  spec.version      = '1.0.2'
  spec.license      = 'FlinkInfo'
  spec.summary      = 'F4 Mobile SDK'
  spec.homepage     = 'http://www.FlinkInfo.com/mobile/F4SDK'
  spec.author       = 'Kut Zhang'
  spec.source       =  {:git => 'http://42.121.104.184/kut/F4SDK_iOS.git', :tag => '1.0.2'}
  spec.source_files = 'F4SDK/**/*.{h,m}'
  spec.requires_arc = true
  spec.dependency 'AFNetworking', '~> 2.4.1'
  spec.dependency 'FMDB', '~> 2.4'
  spec.dependency 'OpenUDID', '~> 1.0.0'
end
