require 'csv'

class StaffStatistic
  MONTH = %w[January February March April May June Jule August September October November December].freeze

  attr_reader :file, :hash_statistic, :general_report, :total_stats

  def file_parser(path)
    @file = CSV.read(path)
    file.delete_if { |row| row[0].strip == 'Name' }
    handle_stats
  end

  def init_staff_hash
    hash = {}
    file.each_with_index do |row, index|
      next if index.zero? || index == 1
      break if row[0].strip == ''
      hash[row[0].strip] = {}
    end
    hash
  end

  def handle_stats
    @total_stats = init_staff_hash.each_pair do |name, hash_stat|
      @hash_statistic = hash_stat
      month_name = ''
      file.each do |row|
        if month_name_in_cell?(row)
          month_name = row[0].strip
          hash_statistic[month_name] = []
        elsif member_staff?(row, name)
          calculate_stats(month_name, row)
        end
      end
    end
    generate_report
  end

  def month_name_in_cell?(row)
    MONTH.include?(row[0].strip)
  end

  def member_staff?(row, name)
    row[0].strip == name
  end

  def calculate_stats(month_name, row)
    %w{sd do av fh}.each { |item| calc_stat(month_name, row, item) }
  end

  def calc_stat(month_name, row, item)
    hash_statistic[month_name] << row.count { |i| i == item }
  end

  def generate_report
    @general_report = []
    write_staff_name
    write_mont_stats
    month_count = total_stats.values.first.count
    general_report.unshift(['Name'] + %w[Month fh sd do av] * month_count)
    create_csv_general_report(general_report)
  end

  def write_mont_stats
    general_report.each do |arr_name|
      total_stats[arr_name.join].each_pair do |month, stat|
        arr_name << month
        stat.each { |el| arr_name << el }
      end
    end
  end

  def write_staff_name
    total_stats.each_key do |staff|
      general_report << [staff]
    end
  end

  def create_csv_general_report(general_report)
    CSV.open('result15.2_my.csv', 'w') do |csv|
      general_report.each do |row|
        csv << row
      end
    end
  end
end

StaffStatistic.new.file_parser('task.csv')
