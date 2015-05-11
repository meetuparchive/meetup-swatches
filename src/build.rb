require 'psych'
require 'json'
require 'erb'
require 'builder'
require 'time'

$: << File.dirname(__FILE__)
require 'lib/string_exts'

color_types = Psych.load_file("./colors.yaml")

# SPECIMEN HTML
@color_types = color_types
template_file = File.open("specimen.erb", 'r').read
erb = ERB.new(template_file)
File.open("../doc/index.html", 'w+') { |file| file.write(erb.result( binding )) }

# SVG SWATCHES
@color_types = color_types
template_file = File.open("svg.erb", 'r').read
erb = ERB.new(template_file)
File.open("../doc/swatches.svg", 'w+') { |file| file.write(erb.result( binding )) }

# REACT JS
js_lines = []
js_lines << "var swatches = {"
color_types.each_value do |color_type|
	js_lines << "// #{color_type["name"]} (#{color_type["comment"]})"
	color_type["colors"].each do |key, value|
			js_lines << "#{key}: 'rgba(#{value.join(',')})',"
	end
	js_lines << " "
end
js_lines << "};"
js_lines << "module.exports = swatches;"
File.open("../react/colors.js", 'w+') do |file|
	file.write(js_lines.join("\n"))
end

# SCSS
# (0.65 - 1) * -100
sass_lines = []
color_types.each_value do |color_type|
	sass_lines << "// #{color_type["name"]} (#{color_type["comment"]})"
	color_type["colors"].each do |key, value|
		if value[3] == 1 # optimize opaque alpha channel to rgb css color
			sass_lines << "$C_#{key}: rgb(#{value[0,3].join(',')});"
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
mapping = Psych.parse_file("colors.yaml").root
File.open("../android/colors.xml", 'w+') do |file|
	xml = Builder::XmlMarkup.new(:target => file, :indent => 2)
	xml.instruct!
	xml.comment! "Generated code: DO NOT EDIT"
	xml.comment! "Last update: #{Time.now.strftime('%B %d, %Y')}"
	xml.resources do
		mapping.children.each_slice(2) do |ignore, color_type|
			xml << "\n"
			xml.comment! color_type.children[1].value
			comment = color_type.children[3].value
			xml.comment! comment unless comment.empty?
			color_type.children[5].children.each_slice(2) do |key, value|
				if value.is_a?(Psych::Nodes::Sequence)
					vals = value.children.rotate(-1).map{|n| n.value.to_f}
					vals[0] = (vals[0] * 255).round # 1.0 -> 0xff
					hexcolor = "#" + vals.map{|c| "%02x" % c.to_i}.join
				else
					hexcolor = "@color/foundation_#{value.anchor.underscore}"
				end
				xml.color hexcolor, {name: "foundation_#{key.value.underscore}"}
			end
		end
	end
end


# IOS
def ios_file_comment_lines(class_name, is_header)
	filename    = is_header ? "#{class_name}.h" : "#{class_name}.m"
	import_line = is_header ? '@import UIKit;'  : %(#import "#{class_name}.h")
	return [
		'//',
		"//  #{filename}",
		'//  MeetupApp',
		'//',
		"//  Generated by Meetup Design on #{Time.now.strftime('%m/%d/%Y')}.",
		"//  Copyright (c) #{Time.now.year} Meetup, Inc. All rights reserved.",
		'//',
		'',
		import_line,
	]
end

def ios_lines(class_name, is_header)
	header_lines = ios_file_comment_lines(class_name, is_header)
	header_lines << (is_header ? "@interface #{class_name} : NSObject" : "@implementation #{class_name}") << ''

	color_types = Psych.load_file('./colors.yaml')
	color_types.each do |color_type_key, color_type|
		header_lines << "#pragma mark - #{color_type['name']}"
		header_lines << ''

		color_type['colors'].each do |color_key, color|
			if is_header
				header_lines << "+ (UIColor *)#{color_key}Color;"
			else
				red   = (color[0].to_f / 255).round(3)
				green = (color[1].to_f / 255).round(3)
				blue  = (color[2].to_f / 255).round(3)
				alpha = (color[3].to_f).round(3)

				header_lines << "+ (UIColor *)#{color_key}Color {"
				header_lines << "    return [UIColor colorWithRed:#{red}f green:#{green}f blue:#{blue}f alpha:#{alpha}f];"
				header_lines << '}'
				header_lines << ''
			end
		end
		header_lines << '' << ''
	end

	header_lines << '@end' << ''
end


ios_class_name = 'MUColor'
File.open("../ios/#{ios_class_name}.h", 'w+') do |file|
	header_lines = ios_lines(ios_class_name, true)
	file.write(header_lines.join("\n"))
end

File.open("../ios/#{ios_class_name}.m", 'w+') do |file|
	header_lines = ios_lines(ios_class_name, false)
	file.write(header_lines.join("\n"))
end
