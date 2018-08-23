require 'erubis'

# Variables
allowed_groups = ['sw', 'ibsw', 'array']

file = ARGV.shift
primary_group = ARGV.shift
name = ARGV.shift

# Functions
def print_help
  puts "Usage"
  puts "  yamdown-add-component FILE PRIMARY_GROUP NAME"
  exit 1
end

# Validation
if file.nil? || ! File.file?(file)
  puts "No such file or directory: #{file}"
  print_help
end

if primary_group.nil? || ! allowed_groups.include?(primary_group)
  puts "Disallowed group: #{primary_group}"
  print_help
end

if name.nil? 
  puts "Invalid name: #{name}"
  print_help
end

# Add to file
template = File.read('templates/flightcenter_component.md.erb')
File.open(file, 'a') { |f| f.write(Erubis::Eruby.new(template).result(binding)) }
