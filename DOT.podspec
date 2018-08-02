
Pod::Spec.new do |s|


  s.name         = "DOT"
  s.version      = "0.0.2"
  s.summary      = "third party app tracking SDK"
  s.description  = <<-DESC
	Upload Dot in CocoaPod third party app tracking SDK
                   DESC
  s.homepage     = "https://github.com/WoncheolHeo/DOT"

  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'WoncheolHeo' => 'fornew21c@gmail.com' }
  s.ios.deployment_target = '8.0'

  s.source       = { :git => "https://github.com/WoncheolHeo/DOT.git", :tag => s.version.to_s }

  s.source_files  = "DOT/**/*"
  s.frameworks = "CouchbaseLite"
end
