#!/usr/bin/env ruby

require 'yaml'
require 'optparse'

@from = 'trac'
@to   = 'hatena'

OptionParser.new do |opt|
  opt.program_name = 'trac - hatena converter'
  opt.version = '0.0.1'

  opt.banner = <<-BANNER
#{opt.ver}
Usage: ruby converter.rb [option OPTION]
  BANNER

  opt.separator('')

  opt.on('--file FILENAME', 'set original file name'){|name|
    @original_filename = name
  }
  opt.on('--from FROM', ['trac', 'hatena'], 'set converting from'){|from|
    @from = from
    @to   = @from == 'trac' ? 'hatena' : 'trac'
  }

  begin
    opt.parse!(ARGV)
  rescue OptionParser::MissingArgument => e
    opt.banner = <<-BANNER
You need to set argument for option

#{opt.banner}
    BANNER

    puts opt.help
    exit
  rescue OptionParser::ParseError, OptionParser::InvalidOption => e
    puts opt.help

    exit
  end
end

def grammers
  _grammers = YAML.load_file('grammers.yaml')

  _grammers.each do |grammer|
    grammer[@from] = Regexp.escape(grammer[@from]).gsub(Regexp.escape('\1'), '(.*)')
  end
end

def convert(str)
  _grammers = grammers

  _grammers.each do |grammer|
    regexp = grammer[@from]
    convert_str = grammer[@to]

    if str =~ /^#{regexp}\n$/
      return str.gsub(/#{regexp}/, convert_str)
    end
  end

  return str
end

File.open(@original_filename) do |original_file|
  original_file.each do |line|
    puts convert(line)
  end
end
