Pod::Spec.new do |s|
  s.name             = "DHStyleString"
  s.version          = "0.2.0"
  s.summary          = "An easy way to created styled NSAttributedString objects."
  s.description      = <<-DESC
                       Create a stylespec (similar to CSS) and then apply it to
                       single strings, multiline strings, or just embed style
                       tags in a large set of text. Result is a NSAttributedString.
                       Much easier than trying to create all of the style dictionaries
                       by hand.
                       DESC
  s.homepage         = "http://github.com/davidahouse/DHStyleString"
  s.license          = 'MIT'
  s.author           = { "David House" => "davidahouse@gmail.com" }
  s.source           = { :git => "https://github.com/davidahouse/DHStyleString.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/davidahouse'

  s.platform     = :ios, '7.0'
  s.ios.deployment_target = '7.0'
  s.requires_arc = true

  s.source_files = 'Classes'
end
