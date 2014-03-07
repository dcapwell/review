require 'yaml'

def to_bash(data)
  data.each do |key, value|
    if value.class == Hash then
      print "#{key}_"
      to_bash(value)
    elsif value.class == Array then
      puts "#{key}=(#{value.join(',')})"
    else
      puts "#{key}=\"#{value}\""
    end
  end
end

data = YAML.load(File.read('.reviewrc'))

to_bash(data)

