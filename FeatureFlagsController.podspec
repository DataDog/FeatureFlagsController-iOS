Pod::Spec.new do |s|
  s.name         = "FeatureFlagsController"
  s.version      = "0.1"
  s.summary      = "Easy Feature Flags management"
  s.description  = <<-DESC
    Register any kind of feature flags (Bool, CaseIterable enum, etc...) in your app and access them automatically at runtime in a nice SwiftUI form.
  DESC
  s.homepage     = "https://github.com/DataDog/FeatureFlagsController-iOS"
  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author             = { "Jérôme Alves" => "j.alves@me.com" }
  s.social_media_url   = ""
  s.ios.deployment_target = "13.0"
  s.source       = { :git => "https://github.com/DataDog/FeatureFlagsController-iOS.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.swift_versions = ["5.3"]
  s.frameworks  = "Foundation"
end
