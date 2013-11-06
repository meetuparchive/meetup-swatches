require 'yaml'
require 'json'
require 'erb'
require 'builder'

$: << File.dirname(__FILE__)
require 'lib/string_exts'

color_types = YAML.load_file("./colors.yaml")

# SCSS
sass_lines = []
color_types.each_value do |color_type|  
  sass_lines << "// #{color_type["comment"]}"
  color_type["colors"].each do |key, value|
    sass_lines << "$C_#{key}: rgba(#{value.join(',')});"
  end
  sass_lines << " "
end 
File.open("../sass/colors.scss", 'w+') do |file|
  file.write(sass_lines.join("\n"))
end

# ANDROID
File.open("../android/colors.xml", 'w+') do |file|
  xml = Builder::XmlMarkup.new(:target => file, :indent => 2)
  xml.instruct!
  xml.resources do
    color_types.each_value do |color_type|
      xml << "\n"
      xml.comment! color_type["comment"]
      color_type["colors"].each do |key, value|
        vals = value.rotate(-1)
        vals[0] = (vals[0] * 255).round # 1.0 -> 0xff
        hexcolor = "#" + vals.map{|c| "%02x" % c.to_i}.join
        xml.color hexcolor, {name: key.underscore}
      end
    end
  end
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

