require 'set'
language_id_map = {}
training_letters_map = {}
language_counter = 0
test_letters_map = {}
test_lines = []
#Read file
File.open('corpus.txt','rb:UTF-16LE').each do |line|
	if rand(10) == 0 #Pick random lines for test set
		test_lines.push(line)
		next
	end
	language = line[-4..-1]
	letters_regex = Regexp.new('^[[:alpha:]]'.encode('UTF-16LE'))
	line2 = line.gsub(letters_regex,'')
	if !language_id_map[language]
		language_id_map[language] = (language_counter += 1)
	end
	language_id = language_id_map[language];
	training_letters_map[language_id] ||= [];
	training_letters_map[language_id].push(SortedSet.new)
	line2.each_char do |char|
		training_letters_map[language_id].last.add(char.ord)
	end
end

#Write training
File.open('training.txt', 'w') do |file|
	training_letters_map.each do |language_id, sentence_array|
		sentence_array.each do |character_set|
			file.write "#{language_id} "
			character_set.each{|c| file.write("#{c}:1 ")}
			file.write "\n"
		end
	end
end

#Write test using stored test_lines
File.open('test.txt', 'w') do |file|
	test_lines.each do |line|
	language = line[-4..-1];
	letters_regex = Regexp.new('^[[:alpha:]]'.encode('UTF-16LE'))
	line2 = line.gsub(letters_regex,'')
	language_id = language_id_map[language];
	test_letters_map[language_id] ||= [];
	test_letters_map[language_id].push(SortedSet.new)
	line2.each_char do |char|
		test_letters_map[language_id].last.add(char.ord)
	end
	end
	test_letters_map.each do |language_id, sentence_array|
		sentence_array.each do |character_set|
			file.write "#{language_id} "
			character_set.each{|c| file.write("#{c}:1 ")}
			file.write "\n"
		end
	end
end

# test_lines.each do |line|
# 	language = line[-4..-1];
# 	letters_regex = Regexp.new('^[[:alpha:]]'.encode('UTF-16LE'))
# 	line2 = line.gsub(letters_regex,'')
# 	language_id = language_id_map[language];
# 	test_letters_map[language_id] ||= [];
# 	test_letters_map[language_id].push(SortedSet.new)
# 	line2.each_char do |char|
# 		test_letters_map[language_id].last.add(char.ord)
# 	end
# end
# language_id_map.each do |language_str, language_id|
# 	utf_8_language_str = language_str[0..1].encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
# 	sentence_array = test_letters_map[language_id]
# 	File.open("test_#{utf_8_language_str}.txt", 'w') do |file|
# 		sentence_array.each do |character_set|
# 			file.write "#{language_id} "
# 			character_set.each{|c| file.write("#{c}:1 ")}
# 			file.write "\n"
# 		end
# 	end
# end

#Run SVM
# C_VALUE = 1.0
# if `./svm_multiclass_learn -c #{C_VALUE} training.txt learned_svm` != 0 
# 	puts "Error: Can't run svm_multiclass_learn"
# end
# if `./svm_multiclass_classify test.txt learned_svm output.txt` != 0
# 	puts "Error: Can't run svm_multiclass_classify"
# end