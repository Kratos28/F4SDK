Pod::Spec.new do |spec|
  spec.name         = 'F4SDK'
  spec.platform     = :ios, '7.0'
  spec.version      = '1.0.2'
  spec.license      = 'MIT'
  spec.summary      = 'F4 Mobile SDK'
  spec.homepage     = 'https://github.com/Kratos28/F4SDK.git'
  spec.author       = 'Kut Zhang'
  spec.source       =  {:git => 'https://github.com/Kratos28/F4SDK.git', :tag => '1.0.2'}
  spec.source_files = 'F4SDKPublic/**/*.{h,m}'
  spec.requires_arc = true
  spec.dependency 'AFNetworking', '~> 2.4.1'
  spec.dependency 'FMDB', '~> 2.4'
  spec.dependency 'OpenUDID', '~> 1.0.0'

end
