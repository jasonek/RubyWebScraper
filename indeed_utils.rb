module IndeedUtils

  def self.create_url_array(nodeset, black_list) # Collect URLs of jobs whose titles pass the Black List Filter
    nodeset.map do |job|
      job["href"] #unless black_list.any? { |bad_word| job["title"].downcase.include?(bad_word) }
    end
  end

  def self.extract_data_from_indeed(html_page, file_name, url, jr_flag) # specific to Indeed.com
    job_title = html_page.css('div[data-tn-component=jobHeader] b.jobtitle').inner_text
    company = html_page.css('div[data-tn-component=jobHeader] span.company').inner_text
    location = html_page.css('div[data-tn-component=jobHeader] span.location').inner_text
    job_summary = html_page.css('span#job_summary').inner_text

    # File.open(file_name, 'w') do |file|
    #   file.write(header.to_html)
    #   file.write(job_summary.to_html)
    # end
    # binding.pry
    [job_title, company, location, job_summary, url, junior_or_senior(job_title)]
  end

  def self.junior_or_senior(title)
    juniors = ['junior', 'jr', 'jr.', 'entry level']
    seniors = ['senior', 'sr', 'sr.', 'lead', 'architect', 'principal', 'director']

    if juniors.any? {|word| title.downcase.include?(word)}
      return 'junior'
    elsif seniors.any? {|word| title.downcase.include?(word)}
      return 'senior'
    else
      return 'mid'
    end
  end

end

module IndeedDB

  def self.insert(db, table, columns)
    # columns_as_string = columns.join(', ')
    # proper_no_qms = ('? ' * columns_array.size).strip
    insert_query = "INSERT INTO #{table}(job_title, company, location, job_summary, listing_url,  junior_flag) VALUES(?, ?, ?, ? ,? ,?)"
    db.execute(insert_query, columns[0], columns[1], columns[2], columns[3], columns[4], columns[5])
  end

end
