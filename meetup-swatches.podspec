Pod::Spec.new do |s|
  s.name         = "meetup-swatches"
  s.version      = "0.0.4"
  s.summary      = "Color swatches for Meetup"
  s.homepage     = "https://github.com/meetup/meetup-swatches"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "Adam Detrick" => "adamd@meetup.com", "Richard Boenigk" => "richard@meetup.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/meetup/meetup-swatches.git", :tag => "v0.0.4" }
  s.source_files  = 'ios/colors.json'
end
