#!/usr/bin/env ruby
#
#

require 'json'
require 'time'

file = File.read('output.json')
data = JSON.parse(file)

first_tx = Time.parse(data[0]['origin']['timestamp'])
last_tx  = Time.parse(data[0]['origin']['timestamp'])

data.each do |tx|
  ts = Time.parse(tx['origin']['timestamp'])
  first_tx = ts if ts < first_tx
  last_tx  = ts if ts > last_tx
end

doubles = data.select { |tx| tx['double']['confirmed'] }

stat = {
  :total => data.length,
  :doubles => doubles.length,
  :percentage => (doubles.length * 100 / data.length),
  :first_tx => first_tx,
  :last_tx => last_tx,
  :period => ((last_tx - first_tx) / (60*60*24)).to_i
}

puts JSON.pretty_generate stat

