require 'set'
language_id_map = {}
training_letters_map = {}
test_letters_map = {}
language_counter = 0
#Read file
File.open('training_corpus.txt','rb:UTF-8').each do |line|
	language = line[-4..-1]
	letters_regex = Regexp.new('^[[:alpha:]]'.encode('UTF-8')) #Only use alphabet characters
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
	File.open('test_corpus.txt','rb:UTF-8').each do |line|
		language = line[-4..-1];
		letters_regex = Regexp.new('^[[:alpha:]]'.encode('UTF-8'))
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

#Run SVM
C_VALUE = ARGV[0] || 10.0
puts `./svm_multiclass_learn -c #{C_VALUE} training.txt learned_svm`
puts `./svm_multiclass_classify test.txt learned_svm output.txt`

#Read test and output files to get statistics
statistics = {total: {TP:0, FP:0, FN:0, TN:0}}
language_id_map.values.each do |id|
	statistics[id] = {
		TP: 0,
		FP: 0,
		FN: 0,
		TN: 0
	}
end
test_file = File.open('test.txt', 'r')
output_file = File.open('output.txt', 'r')
test_file.each.zip(output_file.each).each do |test_line, output_line|
	test_id = test_line.split.first.to_i
	output_id = output_line.split.first.to_i
	if test_id == output_id #Correct classification
		statistics[output_id][:TP] += 1
		statistics[:total][:TP] += 1
		statistics.each do |id, individual_stats| #Increment TN value of all other languages
			if id != output_id
				individual_stats[:TN] += 1 
				statistics[:total][:TN] += 1
			end
		end
	else #Incorrect classification
		statistics[test_id][:FN] += 1
		statistics[:total][:FN] += 1
		statistics[output_id][:FP] += 1
		statistics[:total][:FP] += 1
	end
end
test_file.close and output_file.close

File.open('stats.txt', 'w') do |f|
	pi = rho = big_f = 0
	f.puts "Macro-averaged Precision, Recall, F-measure"
	statistics.each do |id, stats|
		next if id == :total
		language_str = String.new
		language_id_map.each do |str, l_id|
			if id == l_id
				language_str = str[0..1].encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
				break
			end
		end
		f.puts "#{language_str} - TPi:#{stats[:TP]} FPi:#{stats[:FP]} FNi:#{stats[:FN]} TNi:#{stats[:TN]}"
		pi_i = stats[:TP].to_f / (stats[:TP] + stats[:FP])
		rho_i = stats[:TP].to_f / (stats[:TP] + stats[:FN])
		f_i = (2 * pi_i * rho_i) / (pi_i + rho_i)
		f.puts "#{language_str} - pi_i:#{'%.5f' % pi_i} rho_i:#{'%.5f' % rho_i} F_i:#{'%.5f' % f_i}"
		pi += pi_i
		rho += rho_i
		big_f += f_i
	end
	pi /= 13
	rho /= 13
	big_f /= 13
	f.puts "OVERALL - pi:#{'%.5f' % pi} rho:#{'%.5f' % rho} F:#{'%.5f' % big_f}"
	pi = rho = big_f = 0

	f.puts
	f.puts "Micro-averaged Precision, Recall, F-measure"
	pi = statistics[:total][:TP].to_f / (statistics[:total][:TP] + statistics[:total][:FP])
	rho = statistics[:total][:TP].to_f / (statistics[:total][:TP] + statistics[:total][:FN])
	big_f = (2 * pi * rho) / (pi + rho)
	f.puts "OVERALL - pi: #{'%.5f' % pi} rho: #{'%.5f' % rho} F: #{'%.5f' % big_f}"
end