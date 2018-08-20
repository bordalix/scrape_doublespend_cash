#!/usr/bin/env ruby
#
# This script scrapes the website doublespend.cash and puts every
# transaction in a json file, with the following format:
#

require 'nokogiri'
require 'open-uri'
require 'json'

SITE_URL = 'https://doublespend.cash/'
OUTPUT_FILE = './output.json'

$allJSON = []

current_page = 1
last_page = false

# based on current page, returns correct url for page
def getURLfor(page)
  uri = page == 1 ? '' : page.to_s + '.html'
  SITE_URL + uri
end

# parse Input and Output from transaction
def parsePut(obj)
  li = obj.at_css('ul').at_css('li')
  href = li.at_css('a') ? li.at_css('a')['href'] : ''
  aux = {
    :amount => li.at_css('span').text.to_f,
    :address => href.split('/')[-1],
    :explorer => href
  }
end

# parse each Transaction found (original and double)
def parseTx(tx)
  items = tx.at_css("ul[class='list-group']").css('li')
  (input, output) = tx.css('div')
  aux = {
    :confirmed => !!tx.at_css("span[title='Confirmed!']"),
    :raw_data => SITE_URL + tx.at_css("a")['href'],
    :txid => items[0].at_css('a')['href'].split('/')[-1],
    :txid_url => items[0].at_css('a')['href'],
    :timestamp => Time.parse(items[1].text.split("\n")[0].split(': ')[1]),
    :fee => items[3].text.split(' ')[1].to_f,
    :input => parsePut(input),
    :output => parsePut(output)
  }
end

# parse Nokogiri document and add to $allJSON array
def parseForJSON(doc)
  doc.css("div[class='row row-striped']").each do |tx|
    (origin, double) = tx.css("div[class='col-6 tx']")
    $allJSON.push({
      :origin => parseTx(origin),
      :double => parseTx(double)
    })
  end
end

# main loop
while !last_page
  print " scraping page #{current_page}  \r"
  url = getURLfor(current_page)
  begin
    file = open(url)
    doc = Nokogiri::HTML(file)
    parseForJSON(doc)
    current_page += 1
  rescue OpenURI::HTTPError => e
    if e.message == '404 Not Found'
      last_page = true
    else
      raise e
    end
  end
end

# write JSON to file
File.open(OUTPUT_FILE, 'w') { |file| file.write(JSON.pretty_generate($allJSON)) }