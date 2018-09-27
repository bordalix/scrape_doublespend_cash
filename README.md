# Scraping doublespend.cash

### Bitcoin Cash double spends

Double spend is when a set of coins is spent in more than one transaction.
This can happen for various reasons, but one of the reasons is fraud attempts.

Bitcoin Cash accepts 0-conf payments, which I consider insecure by default.
But I would like to have some data to support this, so I went looking.

Since someone developed a website for detecting double spends on the Bitcoin Cash network,
I decided to scrape it and get some numbers from it. The site in question is:

[https://doublespend.cash/](https://doublespend.cash/)

### Numbers

- Date of first transaction, 2018-02-13 11:34:44 +0000
- Date of last transaction, 2018-09-25 10:50:02 +0100
- Period, 223 days
- Number of attempts, 525
- Successful double spends, 117 (22%)
- Double spends with the same output, 58, of which:
  - At least one of the transactions has a low fee, 54
  - Neither transaction has a low fee, 4
- Double spends with a different output, 59, of which:
  - At least one of the transactions has a low fee, 41
  - Neither transaction has a low fee, 18

### Files

**scrap.rb:**
a ruby script, scrapes the website and writes to a json file  
**output.json:** file with all transactions in JSON format  
**stats.rb:** parses the output.json file and delivers some stats

### How do payments work in Bitcoin?

If I want to pay something with bitcoin, I use my wallet to generate a transaction, which is basically composed of two parts:

1. The “input”, where I define the amount, the coin(s) where the amount comes, and a cryptographic proof that I own those coins;

2. The “output”, where I define the amount and the address of the new owner of those coins. If the amount defined in the “output” is less than the amount defined in the “input”, that difference is considered the fee I’m willing to pay to the network to have my transaction processed.

This transaction is then broadcasted throughout the network, and all nodes and miners will eventually know about it, validated it and keep it in memory, in what is called the “mempool”.

Later, miners will peek transactions from this “mempool”, and then try to solve the PoW (“Proof-of-Work”) challenge and if successful, generate a new block which is added to the blockchain after being validated by a majority of nodes and miners.

When a transaction is stored in a block which is now part of the blockchain, we say that that transaction is now “confirmed”.

Keep in mind that miners are free to choose which transactions to include in a block. They can for instance choose the first transactions to arrive, or choose the transactions paying higher fees (since these fees will be earn by the miner which wins the PoW challenge).

The process of generating a new block takes, on average, 10 minutes, which means that payments with bitcoin will take, at least, 10 minutes to be confirmed. That’s a major pitfall for day-to-day payments. Imagine you’re on your favorite coffee shop willing to pay for your expresso. You (and the cashier) will have to await at least 10 minutes before you can get out, which is not practicable.

### Instant payments

Bitcoin Cash (a fork from Bitcoin) decided to circumvent this 10 minutes delay by using transactions still in the mempool (so, with 0 confirmations) as proof of payment. So, with Bitcoin Cash, after I sent the transaction with my wallet, the cashier of the coffee shop would see almost instantly that transaction in the mempool, and would consider the coffee paid.

This is called 0-conf transactions.

But what would happen if, after leaving the shop, I send another transaction, consuming the same coins, but directed to myself? On that instant, two conflicting transactions would be in the mempool, and miners would have to choose one.

And if miners choose the second transaction, and that’s the one mined in a block, than I was able to make a double spend and the coffee shop will not receive any coins at the end.

### Transaction selection

So, in order for 0-conf transactions be secured, the way miners choose the transactions to include in a block is of paramount importance.

In order to try to improve security in 0-conf transactions, Bitcoin Cash decided that miners should use a “first-seen-safe” policy for transaction selection, which means that the first transaction arriving to the mempool should be considered the valid one and later transactions should be ignored.

But remember when I wrote that miners are free to choose which transactions to include in a block? Miners can follow Bitcoin Cash guideline and use “first-seen-safe” or be more economic rational and use a “replace-by-fee” approach, where they choose transactions based on fees (higher fees gain priority).

And since transaction selection is not at the consensus level, the Bitcoin Cash network can have miners using different transaction selection approaches. And since no one keeps a tab of what happens on the mempool, miners can go against the Bitcoin Cash guideline and never get caught.

So, if I want to double spend, I’ve just to send a higher fee on my second transaction and expect to hit a miner using “replace-by-fee”. It will choose the second transaction (the double spend attempt), and try to place it on the blockchain.

Don’t forget that “replace-by-fee” has the potential to give more revenue for the miners, so it should be the more rational option (in economic sense). On the other hand, if the majority of miners in the network uses “replace-by-fee” it would be very easy to double spend, which would destroy the value proposition of Bitcoin Cash, thus destroying all the value in the network and hurting nodes and miners.

### The tragedy of the commons

So, this issue has everything to be a “tragedy of the commons” type of problem.

In order to make some analysis to the network, I used the website [https://doublespend.cash/](https://doublespend.cash/) which detects double spend attempts, and register if they were successful or not.

I build a ruby script to scrap the website and generate a JSON file with all the transactions (518 on the day of writing this post). Than I build a second script to gather some information, and what I found out is astonishing:

- Analysis period from Feb 13 to Sep 19 2018, 217 days;
- There were 518 double spend attempts;
- There are more then 2 double spend attempts per day;
- Of those 518 attempts, 114 attempts were successful;
- Around 22% of all double spend attempts are successful.

It looks like ¼ of the miners are breaking ranks and are not following the “first-seen-safe” rule, exactly as the tragedy of the commons theory predicts.


### Conclusion

Bitcoin Cash 0-conf payments are a very bad idea. The security is based on rules **not** at the consensus level, and rules that are **not** economically rational, so has every thing to go bad.

Bitcoin (BTC) will achieve instant payments via layer 2 scaling, like [Lightning Network](https://lightning.network/).

But that’s a topic for another blog post.