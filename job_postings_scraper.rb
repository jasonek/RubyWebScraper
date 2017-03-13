require 'pry'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'sqlite3'
require 'mechanize'
require_relative 'indeed_utils'

DATA_DIR = "html_pages/indeed"

# User input for job filters
# TITLE_BLACK_LIST = ['senior', 'sr.', 'architect']
# DESCRIPTION_BLACK_LIST = ['3+ years']
JOB_SEARCH = "Ruby developer"
LOCATION = "Los Angeles, CA"

# Create URLs
JOBTITLE_PARAM = URI.encode_www_form("q" => JOB_SEARCH)
LOCATION_PARAM = URI.encode_www_form("l" => LOCATION)
BASE_INDEED_URL = 'https://www.indeed.com/'
SEARCH_URL =  BASE_INDEED_URL + "/jobs" + "?" + JOBTITLE_PARAM + "&" + LOCATION_PARAM + "&fromage=29&limit=100"
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# Create DB and Table
DBNAME = "indeed.sqlite"
DB = SQLite3::Database.open( DBNAME )
TABLE = "postings"
# DB.execute("CREATE TABLE #{TABLE}(job_title, company, location, job_summary,  junior_flag)")

# Prepare variables and data structures before Loop
agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
puts "Querying #{SEARCH_URL}\n\n"
html = agent.get(SEARCH_URL)
results_array = []
i = 2

# Cycle through pages, downloading job description information
loop do
  # Search & Extract data
  next_page = html.link_with(:text => "#{i}")
  page = Nokogiri::HTML(html.body)
  jobs_nodeset = page.css('div.result')
  data_list = IndeedUtils::extract_listing_data(jobs_nodeset, results_array).compact

  # Increment and prepare for next round
  break unless next_page
  i += 1
  html = next_page.click
end
p results_array.size

# Save to DB
results_array.each do |record|
  IndeedDB::insert_postings(DB, TABLE, record)
end
p "Saved #{results_array.count} items to #{DBNAME}.#{TABLE}"
