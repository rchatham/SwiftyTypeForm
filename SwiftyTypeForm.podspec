Pod::Spec.new do |s|
  s.name         = "SwiftyTypeForm"
  s.version      = "0.0.2"
  s.summary      = "TypeForm-like UIViewController subclass."
  s.description  = <<-DESC
  TypeForm-like UIViewController subclass for data collection from user.
                   DESC

  s.homepage     = "https://github.com/rchatham/SwiftyTypeForm"
  s.license      = "MIT"
  s.author             = { "Reid Chatham" => "reid.chatham@gmail.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/rchatham/SwiftyTypeForm.git", :tag => "#{s.version}" }
  s.source_files  = "SwiftyTypeForm", "SwiftyTypeForm/*.swift"
  s.dependency "PhoneNumberKit", "~> 1.0"
end
