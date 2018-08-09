def file_parser_1(path_to_the_file)
  File.write(path_to_the_file, File.read(path_to_the_file).gsub(/\n/, "\n\n"))
end

def file_parser_2(path_to_the_file)
  text = File.read(path_to_the_file).gsub(/\n/, "\n\n")
  File.open(path_to_the_file, 'w') do |f|
    f.write(text)
  end
end

file_parser_2 'task.txt'
