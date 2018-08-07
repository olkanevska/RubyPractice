require 'open-uri'
require 'csv'

def parser_web_page(url)
  html = open(url).read
  create_general_report(html)
end

def select_book_info(books, general_report)
  books.each do |book|
    name = book.scan(/truncate.*?>\n?\s+(.*?)\n\s+<?/m)
    author = book.scan(%r{>(\b\D.*)<\/a})
    rating = book.scan(%r{>(\d.*)<\/a})
    price = book.scan(/>(\$\d+\.\d+)/)
    general_report << name.zip(author, rating, price).flatten
  end
  general_report
end

def create_general_report(html)
  books = html.scan(/truncate.*?price'>\$\d+\.\d+/m)
  general_report = []
  select_book_info(books, general_report)
  general_report.unshift(%w[Name Author Rating Price])
  create_csv_file(general_report)
end

def create_csv_file(general_report)
  CSV.open('result15.3.csv', 'w') do |csv|
    general_report.each do |row|
      csv << row
    end
  end
end

url = 'https://www.amazon.com/gp/bestsellers/digital-text/154606011/ref=s9_ri_ft_clnk?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-10&pf_rd_r=0C8G9TZSPG7PJ5BCQ33E&pf_rd_t=1401&pf_rd_p=1534448702&pf_rd_i=1000493771'
parser_web_page(url)
