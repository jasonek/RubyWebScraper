# RubyWebScraper
There are two Ruby web scrapers/crawlers that were written to work on Indeed.com. The structure of HTML will be different for every website you go to, but many of the general forms and strategies can be reused on any page.

The different use cases for each scraper is outlined below:
* `job_postings_scraper.rb` will query Indeed.com, and will stay on the results page. The results page only gives summary data for each job.
* By contrast, `in_depth_listings_scraper.rb` will do the same query. But instead of staying on the results page, it will follow every job to the in-depth description page. Here it extracts the full description, so more complex parsing can be done on the full description.

# Resources to check out
* [Bastards Book of Ruby, HTML Parsing and Subsequent Chapters](http://ruby.bastardsbook.com/chapters/html-parsing/)
* [Mechanize Gem](http://robdodson.me/crawling-pages-with-mechanize-and-nokogiri/)
* I suggest downloading [DB Browser for SQLite](http://sqlitebrowser.org), so that you can to analyze your data set with SQL.
