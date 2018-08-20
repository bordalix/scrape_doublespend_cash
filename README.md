# Scraping doublespend.cash

### Bitcoin Cash double spends

Double spend is when a set of coins is spent in more than one transaction.
This can happen for various reasons, but one of the reasons is fraud attempts.

Bitcoin Cash accepts 0-conf payments, which I consider insecure by default.
Since someone developed a website for detecting double spends on the Bitcoin Cash network,
I decided to scrape it and get some numbers from it.

### Numbers:

- Total double spend attempts detected: 384
- Total of successful attemps: 107 (27%)

### Files:

- scrap.rb: is a ruby script which scrapes the website and writes to a json file.
- output:json: file where the scraper puts all the transactions in JSON format
- stats.rb: parses the output.json file and delivers some stats

### Conclusion:

A success rate of 27% is crazy!
More than one quarter of double spends are successful.
I now can state, with more confidence, that 0-conf is not secure.