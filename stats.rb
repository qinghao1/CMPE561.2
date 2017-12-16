#Read test and output files to get statistics
statistics = {}
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
		statistics.each do |id, stats| #Increment TN value of all other languages
			stats[:TN] += 1 if id != output_id
		end
	else #Incorrect classification
		statistics[test_id][:FN] += 1
		statistics[output_id][:FP] += 1
	end
end
test_file.close and output_file.close

File.open('stats.txt', 'w') do |f|
	statistics.each do |id, stats|
		language_str = String.new
		language_id_map.each do |str, l_id|
			if id == l_id
				language_str = str[0..1].encode(Encoding.find('UTF-8'), {invalid: :replace, undef: :replace, replace: ''})
				break
			end
		end
		f.puts "#{language_str}- TP:#{stats[:TP]} FP:#{stats[:FP]} FN:#{stats[:FN]} TN:#{stats[:TN]}"
	end
end