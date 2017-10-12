# Open DB and Table
DBNAME = "indeed.sqlite"
DB = SQLite3::Database.open( DBNAME )
TABLE = "full_descriptions"

# Define included and excluded terms
TITLE_SENIOR_LIST = ['senior', 'sr.', 'architect', 'lead', 'principal', 'staff', 'cto', 'vp of engineering']
TITLE_JUNIOR_LIST = ['jr', 'jr.', 'junior', 'entry level', 'recent grad', 'recent graduate', 'software engineer i'] # eng II, III,
# Title filters will put the different jobs into preliminary buckets.
# But the full description will need to be parsed in order to finalize the categorizations
DESCRIPTION_SENIOR_LIST = ['5+ years']

# Examples of the different ways to phrase things:
x = 'whatever'
[ # Many companies have a Company description that says "We have been in business over 40 years". TODO Distinguish between the company part and the job requirements. Could use a numerical one.. if the number is > 20, then disregard
  # or could check if preceeded by 'nearly'
 "at least #{x} years of experience",
 "#{x}+ years professional experience", # Sometimes they have multiple + years of experience for multiple technologies. WAnt to use the Largest as the filter
 "#{x}+ years experience",
 "#{x}+ years of experience",
 "more than #{x}+ years professional experience", #TODO For all of these the + seems to be optional
 "Minimum of #{x} years of experience",
 "At least one year of experience", # Sometimes they spell out the numbers. # TODO: Maybe I need to first replace every word number with the digit
 "Minimum 2-4 years experience",
 "0-5 years of software engineering experience"
 "maximum work experience of 3 years", # Some entry level or junior positions list a MAXIMUM work experience allowed
 "The ideal candidate would have beginning to moderate level experience with html, css, AngularJS and Ruby on Rails.", # Sometimes you see no number
 "Requires 0 to 5 years with BS/BA or 6 to 8 years no degree" # Very complex example. Not sure how I would parse this one
 "- Bachelor’s Degree in Computer Science, or related field, from a four-year college or university, or one to two years related experience and/or training; or equivalent combination of education and experience. Relevant industry certification, such as Oracle Java Developer, is preferred.
    - A minimum of 1-4 years relevant experience in software development", # Another complex one that has different tiers of requirements
 "Java (1-4 years)",
 ]
# TODO: what if there are no numerical year requirements?
