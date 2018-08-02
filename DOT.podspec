
Pod::Spec.new do |s|


  s.name         = "DOT"
  s.version      = "0.0.1"
  s.summary      = "third party app tracking SDK"
  s.description  = <<-DESC
	Upload Dot in CocoaPod third party app tracking SDK
                   DESC
  s.homepage     = "https://github.com/WoncheolHeo/DOT"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = "WiseTracker"
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/WoncheolHeo/DOT.git", :tag => "0.0.1" }

  s.source_files  = "Classes/*.{h,m}"
  s.swift_version = "4.2" 


end
