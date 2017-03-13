require 'pry'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'sqlite3'
require_relative 'indeed_utils'

DATA_DIR = "html_pages/indeed"

# User input for job filters
# TITLE_BLACK_LIST = ['senior', 'sr.', 'architect']
# DESCRIPTION_BLACK_LIST = ['3+ years']
JOB_SEARCH = "Ruby developer"
LOCATION = "San Francisco, CA"

# Create URLs
JOBTITLE_PARAM = URI.encode_www_form("q" => JOB_SEARCH)
LOCATION_PARAM = URI.encode_www_form("l" => LOCATION)
BASE_INDEED_URL = 'https://www.indeed.com/'
SEARCH_URL =  BASE_INDEED_URL + "/jobs" + "?" + JOBTITLE_PARAM + "&" + LOCATION_PARAM + "&fromage=29&limit=100"
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# Create DB and Table
DBNAME = "indeed.sqlite"
# DB = SQLite3::Database.new( DBNAME )
DB = SQLite3::Database.open( DBNAME )
TABLE = "rubydeveloper"
# DB.execute("CREATE TABLE rubydeveloper(job_title, company, location, job_summary, listing_url,  junior_flag)")

# Data structures to save results
array_of_redirections = [] # TODO: Can then iterate through this list at the end.

# Visible Code Begins Here
puts "Querying #{SEARCH_URL}\n\n"
page = Nokogiri::HTML(open(SEARCH_URL))
jobs_nodeset = page.css('h2.jobtitle a.turnstileLink') # This does not find the Sponsored Pages, since I think they are injected dynamically

url_list = IndeedUtils::create_url_array(jobs_nodeset).compact # Remove Nil's
p url_list.count

# Iterate through the pages
url_list.each do |url|
  job_description_url = BASE_INDEED_URL + url
  local_fname = "#{DATA_DIR}/#{File.basename(url)}.html"
  puts "Retrieving #{job_description_url} ..."
  begin
    content = Nokogiri::HTML(open(job_description_url))
  rescue Exception => e
    array_of_redirections << e.to_s.partition('->')[-1] if e.class == RuntimeError # TODO redirections raise a RuntimeError, but so do other things
    puts "Error: #{e}"
    sleep 5
  else
    columns_arr = IndeedUtils::extract_data_from_indeed(content, local_fname, job_description_url)
    IndeedDB::insert(DB, TABLE, columns_arr)
    puts "\t...Success, saved to database"
  ensure
    sleep 2.0 + rand
  end  # done: begin/rescue
end

p array_of_redirections
p array_of_redirections.size
