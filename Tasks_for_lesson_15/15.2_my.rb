require 'csv'

MONTH = %w[January February March April May June Jule August September October November December]

def file_parser(path)
  hash = {}
  file = CSV.read(path)
  file.each_with_index do |row, index|
    next if index.zero? || index == 1
    break if row[0].strip == ''
    hash[row[0].strip] = {}
  end
  file.delete_if { |row| row[0].strip == '' || row[0].strip == 'Name' }
  calculate_stats(hash, file)
end

def calculate_stats(hash, file)
  total_stats = hash.each_pair do |name, hash_statistic|
    month_name = ''
    file.each_with_index do |row, _index|
      if MONTH.include?(row[0].strip)
        month_name = row[0].strip
        hash_statistic[month_name] = []
      elsif row[0].strip == name
        hash_statistic[month_name] << row.count { |item| item == 'fh' }
        hash_statistic[month_name] << row.count { |item| item == 'sd' }
        hash_statistic[month_name] << row.count { |item| item == 'do' }
        hash_statistic[month_name] << row.count { |item| item == 'av' }
      end
    end
  end
  create_generate_report total_stats
end

def create_generate_report(total_stats)
  general_report = []
  total_stats.each_key do |staff|
    general_report << [staff]
  end
  month_count = total_stats[general_report[0].join].count
  general_report.each do |arr_name|
    total_stats[arr_name.join].each_pair do |month, stat|
      arr_name << month
      stat.each { |el| arr_name << el }
    end
  end
  general_report.unshift(['Name'] + %w[Month fh sd do av] * month_count)
  create_csv_general_report(general_report)
end

def create_csv_general_report(general_report)
  CSV.open('result15.2_my.csv', 'w') do |csv|
    general_report.each do |row|
      csv << row
    end
  end
end

file_parser('task.csv')
