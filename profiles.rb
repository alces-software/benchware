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

require 'yaml'

class Profiles

  def initialize(profile, nodes)
    @profile = profile
    @nodes = nodes.split(' ')
    @jobs = {}
    @results = {}
    self.find_jobs()
  end

  def find_jobs()
    #puts "Profile is #{@profile}"
    
    # Collect files
    if @profile != 'all'
      module_files = Dir.glob("profiles/#{@profile}/*.yaml")
    else
      module_files = Dir.glob("profiles/*/*.yaml")
    end

    # Configure module name dict w/ commands from files
    module_files.each do |infile|
      yaml_load = YAML.load_file(infile)
      @jobs[yaml_load['module_name']] = yaml_load['commands']
    end

    # Return
    puts @jobs
  end

  def run_jobs()
    @nodes.each do |node|
      @results[node] = {}
      @jobs.each do |module_name, commands|
        @results[node][module_name] = {}
        commands.each do |command_name, command_cli|
          @results[node][module_name][command_name] = `${command_cli}`
        end
      end
    end
  end

  def results(format)
    if format == 'csv'
      # TODO: actually write the csv output format
      puts "nodename,module_name,"
      @results.each do |node, module_name|
        puts "node,#{module_name},"
      end
    else
      puts @results.to_yaml
    end
  end

end
