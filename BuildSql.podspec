Pod::Spec.new do |s|
  s.name         = "BuildSql"
  s.version      = "1.1.0"
  s.summary      = "Build a SQL statement by code based on Objective-C++."

  s.homepage     = "https://github.com/CUITCHE/buildSQL"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "hejunqiu" => "xiaohe918@vip.qq.com" }
  s.ios.deployment_target = "7.0"
  s.osx.deployment_target = "10.7"
  s.source       = { :git => "https://github.com/CUITCHE/buildSQL.git", :tag => "v#{s.version}" }
  s.source_files = "Classes/*.{h,mm}"
  s.public_header_files = 'Classes/BuildSql.h'
  s.framework    = 'Foundation'
  s.library      = 'c++'
  # use '--skip-import-validation' to validate.
end
