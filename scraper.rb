require 'pry'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require_relative 'indeed_utils'
require_relative 'indeed_db'

DATA_DIR = "html_pages/indeed"
# Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

TITLE_BLACK_LIST = ['senior', 'sr.', 'architect']
DESCRIPTION_BLACK_LIST = ['3+ years']
JOB_SEARCH = "Ruby developer"
LOCATION = "Austin, TX"

JOBTITLE_PARAM = URI.encode_www_form("q" => JOB_SEARCH)
LOCATION_PARAM = URI.encode_www_form("l" => LOCATION)
BASE_INDEED_URL = 'https://www.indeed.com/'
FULL_URL =  BASE_INDEED_URL + "/jobs" + "?" + JOBTITLE_PARAM + "&" + LOCATION_PARAM

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

IndeedDB::create_DB('indeed.sqlite',JOB_SEARCH.gsub(/\s+/, ""))


# Data structures to save results
array_of_redirections = [] # TODO: Can then iterate through this list at the end.

# Visible Code Begins Here
puts "Querying #{FULL_URL}\n\n"
page = Nokogiri::HTML(open(FULL_URL))
job_listing_nodeset = page.css('h2.jobtitle a.turnstileLink') # This does not find the Sponsored Pages, since I think they are injected dynamically

p url_list = IndeedUtils::create_url_array(job_listing_nodeset, TITLE_BLACK_LIST).compact # Remove Nil's

# Iterate through the pages
url_list = url_list[3..3]
url_list.each do |url|
  job_description_url = BASE_INDEED_URL + url + "&fromage=29&limit=50"
  local_fname = "#{DATA_DIR}/#{File.basename(url)}.html"
  puts "Retrieving #{job_description_url} ..."
  begin
    # content = open(job_description_url, HEADERS_HASH).read
    content = Nokogiri::HTML(open(job_description_url))
    # resp = Net::HTTP.get_response(URI.parse(job_description_url))
  rescue Exception => e
    # binding.pry
    array_of_redirections << e.to_s.partition('->')[-1] if e.class == RuntimeError # TODO redirections raise a RuntimeError, but so do other things
    puts "Error: #{e}"
    sleep 5
  else
    IndeedUtils::write_header_and_summary_to_file(content, local_fname)
    puts "\t...Success, saved to #{local_fname}"
  ensure
    sleep 2.0 + rand
  end  # done: begin/rescue
end
