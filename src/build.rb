require 'yaml'
require 'json'
require 'erb'
require 'builder'

$: << File.dirname(__FILE__)
require 'lib/string_exts'

color_types = YAML.load_file("./colors.yaml")

# SPECIMEN HTML
@color_types = color_types
template_file = File.open("specimen.erb", 'r').read
erb = ERB.new(template_file)
File.open("../doc/index.html", 'w+') { |file| file.write(erb.result( binding )) }

# SCSS
# (0.65 - 1) * -100
sass_lines = []
color_types.each_value do |color_type|
	sass_lines << "// #{color_type["comment"]}"
	color_type["colors"].each do |key, value|
		if value[3] == 1 # optimize opaque alpha channel to rgb css color
			sass_lines << "$C_#{key}: rgb(#{value[0,3].join(',')});"
			sass_lines << "@mixin color_#{key}($style: 'color') { \#{$style}: $C_#{key}; }"
		else
			# if it's an inverted color (dark bg), `darken` the opaque equivalent, else `lighten`
			color_func = key["Inverted"] ? "darken" : "lighten"

			sass_lines << "$C_#{key}: rgba(#{value.join(',')});"
			sass_lines << "@mixin color_#{key}($style: 'color') { \#{$style}: #{color_func}( rgb(#{value[0,3].join(',')}), #{((1 - value[3])*100).round}%); \#{$style}: $C_#{key}; }"
		end
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
	palettes = Array.new
	color_types.each do |name, info|
		swatches = Array.new
		info["colors"].each do |name, values|
			converted_values = values.dup
			converted_values[0] = (values[0].to_f/255).round(3)
			converted_values[1] = (values[1].to_f/255).round(3)
			converted_values[2] = (values[2].to_f/255).round(3)
			swatches << { :swatch => name, :values => converted_values }
		end
		palettes << { :palette => name, :comment => info["comment"], :swatches => swatches }
	end
	file.write(JSON.pretty_generate(palettes))
end
