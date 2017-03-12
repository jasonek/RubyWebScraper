module IndeedUtils

  def self.create_url_array(nodeset, black_list) # Collect URLs of jobs whose titles pass the Black List Filter
    nodeset.map do |job|
      job["href"] unless black_list.any? { |bad_word| job["title"].downcase.include?(bad_word) }
    end
  end

  def self.write_header_and_summary_to_file(html_page, file_name) # specific to Indeed.com
    header = html_page.css('div[data-tn-component=jobHeader]')
    job_summary = html_page.css('span#job_summary')

    File.open(file_name, 'w') do |file|
      file.write(header.to_html)
      file.write(job_summary.to_html)
    end
  end

end
