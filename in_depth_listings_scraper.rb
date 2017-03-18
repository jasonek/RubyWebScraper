require 'pry'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'sqlite3'
require 'mechanize'
require_relative 'indeed_utils'

DATA_DIR = "html_pages/indeed"

# User input for job filters
TITLE_BLACK_LIST = ['senior', 'sr.', 'architect', 'lead', 'principal', 'staff']
# DESCRIPTION_BLACK_LIST = ['3+ years']
JOB_SEARCH = "Ruby developer"
LOCATION = "Miami, FL"

# Create URLs
JOBTITLE_PARAM = URI.encode_www_form("q" => JOB_SEARCH)
LOCATION_PARAM = URI.encode_www_form("l" => LOCATION)
BASE_INDEED_URL = 'https://www.indeed.com'
SEARCH_URL =  BASE_INDEED_URL + "/jobs" + "?" + JOBTITLE_PARAM + "&" + LOCATION_PARAM + "&fromage=29&limit=100"
HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

# Create DB and Table
DBNAME = "indeed.sqlite"
# DB = SQLite3::Database.new( DBNAME )
DB = SQLite3::Database.open( DBNAME )
TABLE = "full_descriptions"
# DB.execute("CREATE TABLE #{TABLE}(title, company, location, description, url)")
# DB.execute("DROP TABLE #{TABLE}")#{}"(title, company, location, description, url)")


agent = Mechanize.new { |agent| agent.user_agent_alias = "Mac Safari" }
puts "Querying #{SEARCH_URL}\n\n"
html = agent.get(SEARCH_URL)
array_of_redirections = [] # TODO: Can then iterate through this list at the end.
results_array = []
url_list = []
i = 2

# Save the URL of every job, then follow to the next page of search results and repeat
loop do
  next_page = html.link_with(:text => "#{i}")
  page = Nokogiri::HTML(html.body)
  jobs_nodeset = page.css('h2.jobtitle a.turnstileLink') # This does not find the Sponsored Pages, since I think they are injected dynamically
  IndeedUtils::create_url_array(jobs_nodeset, url_list, TITLE_BLACK_LIST)

  break unless next_page
  i += 1
  html = next_page.click
end

url_list.compact! # Remove Nil's
p url_list.count

# Iterate through every job link, following through to their full description page, to then extract the full description
url_list.each do |url|
  job_description_url = BASE_INDEED_URL + url
  puts "Retrieving: #{job_description_url} ..."
  begin
    loop_agent = Mechanize.new
    loop_page = loop_agent.get(job_description_url)
    full_description_page = Nokogiri::HTML(loop_page.body)
    url_after_redirect = loop_page.uri.to_s
    domain = URI.parse(url_after_redirect).host
  rescue Exception => e
    puts "Error: #{e}"
    sleep 5
  else
    if domain == 'www.indeed.com'
      IndeedUtils::extract_full_description(full_description_page, url_after_redirect, results_array)
      puts "   ...Storing Indeed contents of: #{url_after_redirect}"
    else
      array_of_redirections << url_after_redirect
      puts "\t...Saved to array_of_redirections: #{url_after_redirect}"
    end

  ensure
    sleep 2.0 + rand
  end
end


# Will have to clean array of hashes from empty strings
# results_array.map {|hash| hash unless hash[:description].empty?  }.compact

p "Results array is of size: #{results_array.size}"
p "array_of_redirections is of size: #{array_of_redirections.size}"


# DB stuff
results_array.each do |record|
  IndeedDB::insert_in_depth_listings(DB, TABLE, record)
end
p "Saved #{results_array.count} items to #{DBNAME}.#{TABLE}"
