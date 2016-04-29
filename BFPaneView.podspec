Pod::Spec.new do |s|
  s.name         = "BFPaneView"
  s.version      = "0.0.1"
  s.summary      = "An interactive pane view for iOS."
  s.license      = { :type => "MIT" }
  s.homepage     = "https://github.com/bradfol/BFPaneView"
  s.author       = "Brad Fol"
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/bradfol/BFPaneView.git", :tag => "0.0.1" }
  s.source_files  = "BFPaneView/*.swift"
  s.framework  = "UIKit"
end
