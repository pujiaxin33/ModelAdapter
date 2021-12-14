
Pod::Spec.new do |s|
  s.name         = "ModelAdapter"
  s.version = "0.0.8"
  s.summary      = "ModelAdapter"
  s.homepage     = "https://github.com/pujiaxin33/ModelAdapter"
  s.license      = "MIT"
  s.author       = { "pujiaxin33" => "317437084@qq.com" }
  s.platform     = :ios, "9.0"
  s.swift_version = "5.1"
  s.source       = { :git => "https://github.com/pujiaxin33/ModelAdapter.git", :tag => "#{s.version}" }
  s.framework    = "UIKit"
  s.source_files  = "Sources", "Sources/**/*.{swift}"
  s.requires_arc = true
  
  s.dependency 'SQLite.swift'
  s.dependency 'SQLiteValueExtension', '~> 0.0.7'
end
