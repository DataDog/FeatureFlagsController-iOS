Pod::Spec.new do |s|
  s.name         = "FeatureFlagsController"
  s.version      = "0.1"
  s.summary      = ""
  s.description  = <<-DESC
    Your description here.
  DESC
  s.homepage     = "https://github.com/DataDog/FeatureFlagsController"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Jérôme Alves" => "j.alves@me.com" }
  s.social_media_url   = ""
  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/DataDog/FeatureFlagsController.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
