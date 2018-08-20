#!/usr/bin/env ruby
#
#

require 'json'

file = File.read('output.json')
data = JSON.parse(file)

doubles = data.select { |tx| tx['double']['confirmed'] }

stat = {
  :total => data.length,
  :doubles => doubles.length,
  :percentage => (doubles.length * 100 / data.length)
}

puts stat

