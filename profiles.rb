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
require 'erubis'

class Profiles

  def initialize(options)
    @profile = options['profile']
    @nodes = options['nodes'].split(' ')
    @output = options['output']
    @file = options['file']
    @row_height = options['row_height']
    @quiet = options['quiet']
    @verbose = options['verbose']
    @verbose_log = '/var/log/benchware.log'
    @jobs = {}
    @results = {}
    @meta = YAML.load_file("profiles/meta.yaml")
    self.find_jobs()
  end

  def find_jobs()
    # Collect files
    if @profile != 'all'
      module_files = Dir.glob("profiles/#{@profile}/*.yaml").sort
    else
      module_files = Dir.glob("profiles/*/*.yaml").sort
    end

    # Configure module name dict w/ commands from files
    module_files.each do |infile|
      yaml_load = YAML.load_file(infile)
      @jobs[yaml_load['module_name']] = yaml_load.dup.tap { |h| h.delete('module_name') }
    end

    if @verbose
      # Write to global log
      File.open(file, 'a') { |f| f.write("#{Time.now} - Running Benchware with the following options - "\
                                        "profile = #{@profile}, nodes = #{@nodes}, output = #{@output}, file = #{@file}"\
                                        "quiet = #{@quiet}, jobs = #{@jobs}")}
    end
  end

  def _sanitise_cmdline(command)
    # Properly escape $
    clean = command.gsub('$','\\$')
    return clean
  end

  def _run_meta(node, command_cli)
    command = command_cli.sub('ENTRY', node)
    out = `#{command}`
    return out
  end

  def _run_cmd(node, command)
    out = `ssh #{node} "#{self._sanitise_cmdline(command)}"`
    return out
  end

  def _run_script(node, script, entry=nil)
    out = `ssh #{node} "bash -l -s" -- < #{script} #{entry}`
    return out
  end

  def run_jobs()
    @nodes.each do |node|

      # Prepare results hash structure
      @results[node] = {}

      # Gather metadata from localhost
      @meta['commands'].each do |command_name, command_cli|
        @results[node][command_name] = self._run_meta(node, command_cli).tr("\n", "")
      end

      # Run the rest of the jobs
      @jobs.each do |module_name, details|

        # Install dependencies
        if details.key?('dependencies')
          # Captures all dependency install output and prepends the nodename
          out = self._run_cmd(node, "yum install -y #{dependencies}").split("\n").map {|l| "#{node}: #{l}" }.join("\n")
          if @verbose
            # Write to global log
            File.open(file, 'a') { |f| f.write(out)}
          end
        end

        @results[node][module_name] = {}
        if details['repeat_list']
          run_list = self._run_cmd(node, details['repeat_list']).split(/\n/)
          run_list.each do |entry|
            @results[node][module_name][entry] = {}
          end
        end

        # Run commands
        if details.key?('commands')
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
        end

        # Run scripts
        if details.key?('scripts')
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

      end

      if @file
        case @output
        when 'md'
          File.write(@file, self._to_md(@results))
        when 'yaml'
          File.write(@file, @results.to_yaml)
        when 'yamdown'
          File.write(@file, self._to_yamdown(@results))
        else
          puts "Output format #{@output} is unknown to benchware, using yamdown"
          File.write(@file, self._to_yamdown(@results))
        end
      end
    end
    puts "Results written to #{@file}"
  end

  def _continue
    puts "Press any key to continue"
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
        row_num += 1
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

  def _to_yamdown(data)
    content = []
    template = File.read('templates/flightcenter.md.erb')
    data.each do |node, node_data|
      content << "#{node}:"
      content << "  name: #{node}"
      content << "  primary_group: #{node_data['primary_group']}"
      content << "  secondary_group: #{node_data['secondary_groups']}"
      content << "  info: |"
      content << Erubis::Eruby.new(template).result(binding)
      content << ""
    end
    return content.join("\n")
  end

  def results()
    unless @quiet
      self._page_output(@results)
    end
  end

end
