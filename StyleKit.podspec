Pod::Spec.new do |s|

  s.name         = "StyleKit"
  s.version      = "0.3.0"
  s.summary      = "A powerful & easy to use styling framework written in Swift."

  s.description  = "StyleKit is a microframework that enables you to style your applications using a simple JSON file. Behind the scenes, StyleKit uses UIAppearance and some selector magic to apply the styles. You can also customize the parser for greater flexibility."

  s.homepage     = "https://github.com/146BC/StyleKit"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Bernard Gatt" => "bernard@blinkrocket.com" }
  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/146BC/StyleKit.git", :tag => "#{s.version}" }

  s.source_files  = "StyleKit/*.{swift,h,m}", "StyleKit/**/*.{swift,h,m}"

end