#!/usr/bin/env ruby
#
#

require 'json'
require 'time'

showTimestamps = ARGV[0] && ARGV[0] == 'full'

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

# check for doubles with the same output
same_output = doubles.select { |tx| tx['origin']['output']['address'] == tx['double']['output']['address'] }
diff_output = doubles.select { |tx| tx['origin']['output']['address'] != tx['double']['output']['address'] }

# check for low fees in transactions
same_output_low_fee  = same_output.select { |tx| tx['origin']['fee'] <  1 || tx['double']['fee'] <  1 }
same_output_high_fee = same_output.select { |tx| tx['origin']['fee'] >= 1 && tx['double']['fee'] >= 1 }
diff_output_low_fee  = diff_output.select { |tx| tx['origin']['fee'] <  1 || tx['double']['fee'] <  1 }
diff_output_high_fee = diff_output.select { |tx| tx['origin']['fee'] >= 1 && tx['double']['fee'] >= 1 }

stats = {
  :first_tx_timestamp => first_tx,
  :last_tx_timestamp => last_tx,
  :period_in_days => ((last_tx - first_tx) / (60*60*24)).to_i,
  :total_number_of_doublespend_attempts => data.length,
  :successful_doublespend_attempts => doubles.length,
  :success_rate => (doubles.length * 100 / data.length).to_i.to_s + '%',
  :doublespend_attempts_with_same_output => {
    :count => same_output.length,
    :at_least_one_tx_has_a_low_fee => same_output_low_fee.length,
    :neither_tx_has_a_low_fee => {
      :count => same_output_high_fee.length,
      :timestamps => showTimestamps ?
                     same_output_high_fee.map {|tx| tx['origin']['timestamp']} :
                     "use './stats.rb full' to see timestamps"
    }
  },
  :doublespend_attempts_with_different_output => {
    :count => diff_output.length,
    :at_least_one_tx_has_a_low_fee => diff_output_low_fee.length,
    :neither_tx_has_a_low_fee => {
      :count => diff_output_high_fee.length,
      :timestamps => showTimestamps ?
                     diff_output_high_fee.map {|tx| tx['origin']['timestamp']} :
                     "use './stats.rb full' to see timestamps"
    }
  }
}

puts JSON.pretty_generate stats
