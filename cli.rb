#==============================================================================
# Copyright (C) 2018 Stephen F. Norledge and Alces Software Ltd.
#
# This file/package is part of Alces benchware.
#
# Alces benchware is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# Alces benchware is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this package.  If not, see <http://www.gnu.org/licenses/>.
#
# For more information on the Alces benchware, please visit:
# https://github.com/alces-software/benchware
#==============================================================================

require 'optparse'

class MainParser

  def self.parse(args)
  options = {}
  #profiles = ['all', 'inv', 'diag', 'perf']
  profiles = ['all'] + Dir.glob('profiles/*').map{ |x| File.basename(x) }
  formats = ['yaml', 'yamdown']

  # Defaults
  options['output'] = 'yamdown'
  options['profile'] = 'all'
  options['file'] = "/tmp/benchware.out.#{('a'..'z').to_a.shuffle[0,8].join}"
  options['row_height'] = 30
  options['quiet'] = false
  options['verbose'] = false

  opt_parser = OptionParser.new do |opt|
    opt.banner = "Usage: benchware [OPTIONS] -n \"NODES\""
    opt.separator  ""
    opt.separator  "Options:"

    opt.on("-p","--profile PROFILE","profile of checks to run","  all - Runs all profiles [default]","  inv - System information only","  diag - Run diagnostic checks","  perf - Run performance tests", "any directory in profiles/ is a valid profile") do |prof|
      if profiles.include? prof
        options['profile'] = prof
      else
        puts "No such profile - #{prof}"
        exit 1
      end
    end

    opt.on("-n","--nodes \"NODE1 NODE2\"","space separated list of nodes to run on") do |nodeslist|
      options['nodes'] = nodeslist
    end

    opt.on("-o","--output FORMAT","format for data to be output in, can be one of: #{formats.join(' ')}") do |format|
      options['output'] = format
    end

    opt.on("-f","--file FILE","file to write command output to") do |filename|
      options['file'] = filename
    end

    opt.on("-l","--length LENGTH",Integer,"the height of the paged output") do |height|
      options['row_height'] = height
    end

    opt.on("-q","--quiet","don't display results in terminal, useful for just writing to a file") do |quiet|
      options['quiet'] = quiet
    end

    opt.on("-v","--verbose","create additional debug info in /var/log/benchware.log") do |verbose|
      options['verbose'] = verbose
    end

    opt.on("-h","--help","show this help screen") do
        puts opt
        exit
      end
  end

  # Remove options from ARGV and store within opt_parser object
  opt_parser.parse!(args)

  if !options['nodes']
    puts "No nodes specified"
    exit 1
  end

  # Return options
  return options

  end
end
