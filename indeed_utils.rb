module IndeedUtils
  def self.create_url_array(nodeset,array, black_list) # Collect URLs of jobs whose titles pass the Black List Filter
    # nodeset.map { |job| job["href"] }#unless black_list.any? { |bad_word| job["title"].downcase.include?(bad_word) }
    nodeset.each do |job|
      array << job["href"] unless black_list.any? { |bad_word| job["title"].downcase.include?(bad_word) }
    end
  end

  def self.extract_listing_data(nodeset, array)
    nodeset.map do |listing|
      array << {
      :title => listing.css('[title]')[0].text.strip,
      :company => listing.css('span.company').text.strip,
      :location => listing.css('span.location').text.strip,
      :summary => listing.css('span.summary').text.strip,
      :junior_flag => junior_or_senior(listing.css('[title]')[0].text.strip) # Checking job title for Jr or Sr key words
    }
    end
  end

  def self.extract_full_description(html_page, url, array)
    array << {
    :title => html_page.css('div[data-tn-component=jobHeader] b.jobtitle').inner_text,
    :company => html_page.css('div[data-tn-component=jobHeader] span.company').inner_text,
    :location => html_page.css('div[data-tn-component=jobHeader] span.location').inner_text,
    :description => html_page.css('span#job_summary').inner_text,
    :url => url
    # binding.pry
  }
    # [job_title, company, location, job_summary, url, junior_or_senior(job_title)]
  end

  def self.junior_or_senior(title)
    juniors = ['junior', 'jr', 'jr.', 'entry level', 'recent grad']
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
  def self.insert_in_depth_listings(db, table, hash)
    insert_query = "INSERT INTO #{table}(title, company, location, description, url) VALUES(?, ?, ?, ?, ?)"
    db.execute(insert_query, hash[:title], hash[:company], hash[:location], hash[:description], hash[:url])
  end

  def self.insert_postings(db, table, hash)
    insert_query = "INSERT INTO #{table}(job_title, company, location, job_summary, junior_flag) VALUES(?, ?, ? ,? ,?)"
    db.execute(insert_query, hash[:title], hash[:company], hash[:location], hash[:summary], hash[:junior_flag])
  end

  def self.save_redirects()
    
  end
end
