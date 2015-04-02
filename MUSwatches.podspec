Pod::Spec.new do |s|
  s.name         = "MUSwatches"
  s.version      = "0.6.2"
  s.summary      = "Color swatches for Meetup"
  s.homepage     = "https://github.com/meetup/meetup-swatches"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.authors      = { "Adam Detrick" => "adamd@meetup.com", "Richard Boenigk" => "richard@meetup.com" }
  s.platform     = :ios
  s.source       = { :git => "https://github.com/meetup/meetup-swatches.git", :tag => "v0.6.2" }
  s.requires_arc = true
  s.source_files = "ios/**/*.{h,m}"
  s.public_header_files = "ios/**/*.h"
end
