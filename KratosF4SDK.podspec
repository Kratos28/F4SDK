Pod::Spec.new do |spec|

  spec.name         = 'KratosF4SDK'
  spec.platform     = :ios, '8.0'
  spec.version      = '1.0.2'
  spec.license      = 'FlinkInfo'
  spec.summary      = 'F4 Mobile SDK'
  spec.homepage     = 'https://github.com/Kratos28/F4SDK.git'
  spec.author       = 'Kut Zhang'
  spec.source       =  {:git => 'https://github.com/Kratos28/F4SDK.git', :tag => '1.0.2'}
  spec.source_files = 'KratosF4SDK/**/*.{h,m}'
  spec.requires_arc = true
spec.dependency 'AFNetworking', '~> 2.5.4'
spec.dependency 'FMDB', '~> 2.4'
spec.dependency 'OpenUDID', '~> 1.0.0'
end
