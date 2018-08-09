require 'open-uri'
require 'csv'

class Books
  attr_reader :html, :books, :general_report

  def web_page_parser(url)
    @html = open(url).read # rubocop:disable Security/Open
    create_general_report
  end

  def create_general_report
    @general_report = []
    find_books_info
    handle_books_info
    general_report.unshift(%w[Name Author Rating Price])
    create_csv_general_report
  end

  def find_books_info
    @books = html.scan(/truncate.*?price'>\$\d+\.\d+/m)
  end

  def handle_books_info
    books.each do |book|
      name = book.scan(/truncate.*?>\n?\s+(.*?)\n\s+<?/m)
      author = book.scan(%r{>(\b\D.*)<\/a})
      rating = book.scan(%r{>(\d.*)<\/a})
      price = book.scan(/>(\$\d+\.\d+)/)
      general_report << name.zip(author, rating, price).flatten
    end
  end

  def create_csv_general_report
    CSV.open('result15.3.csv', 'w') do |csv|
      general_report.each do |row|
        csv << row
      end
    end
  end
end

url = 'https://www.amazon.com/gp/bestsellers/digital-text/154606011/ref=s9_ri_ft_clnk?pf_rd_m=ATVPDKIKX0DER&pf_rd_s=center-10&pf_rd_r=0C8G9TZSPG7PJ5BCQ33E&pf_rd_t=1401&pf_rd_p=1534448702&pf_rd_i=1000493771'
Books.new.web_page_parser(url)
