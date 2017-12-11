require 'set'
training_letters_map = {}
test_letters_map = {}
test_lines = []
#Read file
File.open('corpus.txt','rb:UTF-16LE').each do |line|
	if rand(10) == 0 
		test_lines.push line
		next
	end
	language = line[-4..-1];
	letters_regex = Regexp.new('^[[:alpha:]]'.encode('UTF-16LE'))
	line2 = line.gsub(letters_regex,'')
	line2.each_char do |char|
		training_letters_map[language] ||= SortedSet.new
		training_letters_map[language].add(char.ord)
	end
end

#Write training
File.open('training.txt', 'w') do |file|
	language_counter = 0;
	training_letters_map.each do |language_id, characters|
		file.write "#{language_counter+=1} "
		characters.each{|c| file.write("#{c}:1 ")}
		file.write "\n"
	end
end

#Write test using stored test_lines
File.open('test.txt', 'w') do |file|
	test_lines.each do |line|
	language = line[-4..-1];
	letters_regex = Regexp.new('^[[:alpha:]]'.encode('UTF-16LE'))
	line2 = line.gsub(letters_regex,'')
	line2.each_char do |char|
		test_letters_map[language] ||= SortedSet.new
		test_letters_map[language].add(char.ord)
	end
	end
	language_counter = 0;
	test_letters_map.each do |language_id, characters|
		file.write "#{language_counter+=1} "
		characters.each{|c| file.write("#{c}:1 ")}
		file.write "\n"
	end
end