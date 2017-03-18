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
# DB.execute("CREATE TABLE #{TABLE}(job_title, company, location, job_summary, listing_url,  junior_flag)")


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
  puts "Retrieving #{job_description_url} ..."
  begin
    loop_agent = Mechanize.new
    loop_page = loop_agent.get(job_description_url)
    full_description_page = Nokogiri::HTML(loop_page.body)
    post_redirect_url = loop_page.uri.to_s
    domain = URI.parse(post_redirect_url).host
    binding.pry
    # full_description_page = Nokogiri::HTML(open(job_description_url))
  rescue Exception => e
    # array_of_redirections << e.to_s.partition('->')[-1] if e.class == RuntimeError # TODO redirections raise a RuntimeError, but so do other things. Need a better filter for redirections. Maybe check for Status: 302 ?
    puts "Error: #{e}"
    sleep 5
  else
    if host == 'www.indeed.com'
      IndeedUtils::extract_full_description(full_description_page, post_redirect_url, results_array)
    else
      array_of_redirections << post_redirect_url
    end
    # IndeedDB::insert_in_depth_listings(DB, TABLE, columns_arr)
    puts "\t...Success, saved to database"
  ensure
    sleep 2.0 + rand
  end  # done: begin/rescue
  binding.pry
end

# Will have to clean array of hashes from empty strings
# results_array.map {|hash| hash unless hash[:description].empty?  }.compact

# Do DB stuff down here

p array_of_redirections.size

# TODO: Redirections save to extract_full_description as empty strings.
