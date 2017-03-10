require 'pry'
require 'nokogiri'
require 'open-uri'

DATA_DIR = "html_pages/indeed"
# Dir.mkdir(DATA_DIR) unless File.exists?(DATA_DIR)

TITLE_BLACK_LIST = %w(senior sr. architect)
JOB_SEARCH = "Ruby developer"
LOCATION = "Los Angeles, CA"

JOBTITLE_PARAM = URI.encode_www_form("q" => JOB_SEARCH)
LOCATION_PARAM = URI.encode_www_form("l" => LOCATION)
BASE_INDEED_URL = 'https://www.indeed.com/'
FULL_URL =  BASE_INDEED_URL + "/jobs" + "?" + JOBTITLE_PARAM + "&" + LOCATION_PARAM

HEADERS_HASH = {"User-Agent" => "Ruby/#{RUBY_VERSION}"}

puts "Querying #{FULL_URL}\n\n"
page = Nokogiri::HTML(open(FULL_URL))
job_listing_nodeset = page.css('h2.jobtitle a.turnstileLink') # This does not find the Sponsored Pages, since I think they are injected dynamically


# I don't necessarily need the hash. I could just collect a list of URI's whose titles have already been filtered.
# Then when I inspect job descriptions further and filter, I could only worry about the title then

# filtered_hash = {}
# i = 1;
# job_listing_nodeset.each do |job|
#   filtered_hash["listing #{i}"] = {
#     "title" => job["title"], "href" => job["href"]
#   } unless BLACK_LIST.any? { |bad_word| job["title"].downcase.include?(bad_word) }
#   i += 1
# end
# p filtered_hash



# Collect URLs of jobs whose titles pass the Filter test
url_list = job_listing_nodeset.map do |job|
  job["href"] unless TITLE_BLACK_LIST.any? { |bad_word| job["title"].downcase.include?(bad_word) }
end

p url_list

# Begin downloading the pages
url_list = url_list[0..0]
url_list.each do |url|
  job_description_url = BASE_INDEED_URL + url
  local_fname = "#{DATA_DIR}/#{File.basename(url)}.html"
  puts "Retrieving #{job_description_url} ..."
  begin
    # content = open(job_description_url, HEADERS_HASH).read
    content = Nokogiri::HTML(open(job_description_url))
  rescue Exception => e
    puts "Error: #{e}"
    sleep 5
  else
    header = content.css('div[data-tn-component=jobHeader]').to_html
    job_summary = content.css('span#job_summary').to_html
    File.open(local_fname, 'w') do |file|
      file.write(header)
      file.write(job_summary)
    end
    puts "\t...Success, saved to #{local_fname}"
  ensure
    sleep 2.0 + rand
  end  # done: begin/rescue
end
