#!/usr/bin/env ruby
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

$LOAD_PATH << File.dirname(__FILE__)

# Requirements
require 'cli'
require 'profiles'

# Parse arguments
options = MainParser.parse(ARGV)

# Run Command
run_profile = Profiles.new(options['profile'], options['nodes'])
run_profile.run_jobs()
run_profile.results(options['output'])
