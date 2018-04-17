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
require 'cli/ui'
require 'io/console'

class Profiles

  def initialize(options)
    @profile = options['profile']
    @nodes = options['nodes'].split(' ')
    @output = options['output']
    @file = options['file']
    @row_height = options['row_height']
    @quiet = options['quiet']
    @jobs = {}
    @results = {}
    self.find_jobs()
  end

  def find_jobs()
    # Collect files
    if @profile != 'all'
      module_files = Dir.glob("profiles/#{@profile}/*.yaml")
    else
      module_files = Dir.glob("profiles/*/*.yaml")
    end

    # Configure module name dict w/ commands from files
    module_files.each do |infile|
      yaml_load = YAML.load_file(infile)
      @jobs[yaml_load['module_name']] = yaml_load.dup.tap { |h| h.delete('module_name') }
    end
  end

  def _sanitise_cmdline(command)
    # Properly escape $
    clean = command.gsub('$','\\$')
    return clean
  end

  def _run_cmd(node, command)
    out = `ssh #{node} "#{self._sanitise_cmdline(command)}"`
    return out
  end

  def _run_script(node, script, entry=nil)
    out = `ssh #{node} "bash -s" -- < #{script} #{entry}`
    return out
  end

  def run_jobs()
    @nodes.each do |node|

      # Prepare results hash structure
      @results[node] = {}
      @jobs.each do |module_name, details|
        @results[node][module_name] = {}
        if details['repeat_list']
          run_list = self._run_cmd(node, details['repeat_list']).split(/\n/)
          run_list.each do |entry|
            @results[node][module_name][entry] = {}
          end
        end

        # Run commands
        details['commands'].each do |command_name, command_cli|
          if details.key?('repeat_list')
            run_list.each do |entry|
              run_cmd = command_cli.sub('ENTRY', entry)
              @results[node][module_name][entry][command_name] = self._run_cmd(node, run_cmd).tr("\n", "")
            end
          else
            @results[node][module_name][command_name] = self._run_cmd(node, command_cli).tr("\n", "")
          end
        end

        # Run scripts
        details['scripts'].each do |script_name, script_path|
          if details.key?('repeat_list')
            run_list.each do |entry|
              @results[node][module_name][entry][script_name] = self._run_script(node, script_path, entry).tr("\n", "")
            end
          else
            @results[node][module_name][script_name] = self._run_script(node, script_path).tr("\n", "")
          end
        end
      end
      File.write(@file, @results.to_yaml)
    end
  end

  def _continue
    print "Press any key to continue"
    STDIN.getch
  end

  def _page_output(data)
    
    CLI::UI::StdoutRouter.enable
    row_max = @row_height

    data.each do |node, node_data|
      system('clear')
      puts node
      row_num = 1
      node_data.each do |module_name, module_commands|
        puts "  #{module_name}:"
        module_commands.each do |command, output|
          if output.class == Hash
            puts "    #{command}:"
            row_num += 1
            output.each do |entry, out|
              puts "      #{entry}: #{out}"
              row_num += 1
            end
          else
            puts "    #{command}: #{output}"
            row_num += 1
          end
          if row_num >= row_max
            self._continue
            system('clear')
            puts node
            row_num = 1
          end
        end
      end
      self._continue
    end
  end

  def results()
    unless @quiet
      if @format == 'csv'
        # TODO: actually write the csv output format
        puts "nodename,module_name,"
        @results.each do |node, module_name|
          puts "node,#{module_name},"
        end
      else
        #puts @results.to_yaml
        self._page_output(@results)
      end
    end
  end

end
