module IndeedUtils

  def self.create_url_array(nodeset, black_list) # Collect URLs of jobs whose titles pass the Black List Filter
    nodeset.map do |job|
      job["href"] unless black_list.any? { |bad_word| job["title"].downcase.include?(bad_word) }
    end
  end

  def self.extract_data_from_indeed(html_page, file_name, url) # specific to Indeed.com
    job_title = html_page.css('div[data-tn-component=jobHeader] b.jobtitle').inner_text
    company = html_page.css('div[data-tn-component=jobHeader] span.company').inner_text
    location = html_page.css('div[data-tn-component=jobHeader] span.location').inner_text
    job_summary = html_page.css('span#job_summary')
    binding.pry

    # File.open(file_name, 'w') do |file|
    #   file.write(header.to_html)
    #   file.write(job_summary.to_html)
    # end
    [job_title, company, location, job_summary, url]
  end

end

module IndeedDB

  def insert(db, table, columns_array)
    columns_as_string = columns_array.join(' ')
    proper_no_?s = ('? ' * columns_array.size).strip
    insert_query = "INSERT INTO #{table}(#{columns_as_string}) VALUES(#{proper_no_?s})"
    db.execute(insert_query, jobtitle, listingurl, loc, jrflag)
  end

end
