require 'rubygems'
require 'sqlite3'



module IndeedDB

  def insert(db, jobtitle, listingurl, loc, jrflag)
    insert_query = "INSERT INTO #{table}(job_title, listing_url, location, junior_flag) VALUES(?, ?)"
    db.execute(insert_query, jobtitle, listingurl, loc, jrflag)
  end

end





# db_name = indeed.sqlite
# table_name = job titl search terms





# 
# [Numeric, String, Array, IO, Kernel, SQLite3, NilClass, MatchData].each do |klass|
#   puts "Inserting methods for #{klass}"
#
#   # a second loop: iterate through each method
#   klass.methods.each do |method_name|
#     # Note: method_name is actually a Symbol, so we need to convert it to a String
#     # via .to_s
#     DB.execute(insert_query, klass.to_s, method_name.to_s)
#   end
# end
