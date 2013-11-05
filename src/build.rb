require 'yaml'
require 'json'
require 'erb'

color_types = YAML.load_file("./colors.yaml")

# SCSS
sass_lines = []
color_types.each_value do |color_type|  
  sass_lines << "// #{color_type["comment"]}"
  color_type["colors"].each do |key, value|
    sass_lines << "$C_#{key}: rgba(#{value[0]},#{value[1]},#{value[2]},#{value[3]});"
  end
  sass_lines << " "
end 
File.open("../sass/colors.scss", 'w+') do |file|
  file.write(sass_lines.join("\n"))
end

# ANDROID
android_lines = []
color_types.each_value do |color_type|
  android_lines << "<!--  #{color_type["comment"]} -->"
  color_type["colors"].each do |key, value|
    vals = value.dup
    vals[3] = vals[3] * 100
    vals_hexed = vals.map do |v|
      "%02X" % v.to_i
    end
    value_hexed = "##{vals_hexed[3]}#{vals_hexed[0]}#{vals_hexed[1]}#{vals_hexed[2]}"
    android_lines << "<color name=\"#{key}\">#{value_hexed}</color>"
  end
  android_lines << " "
end 
File.open("../android/colors.xml", 'w+') do |file|
  file.write(android_lines.join("\n"))
end

# IOS
File.open("../ios/colors.json", 'w+') do |file|
  file.write(JSON.pretty_generate(color_types))
end

# SPECIMEN HTML
@color_types = color_types
template_file = File.open("specimen.erb", 'r').read
erb = ERB.new(template_file)
File.open("../doc/specimen.html", 'w+') { |file| file.write(erb.result( binding )) }

