# Instructions
1. Run part2.rb in console i.e. `ruby part2.rb`
2. Train with a c-value (1.0 here) `./svm_multiclass_learn -c 1.0 training.txt learned_svm`
3. Classify `./svm_multiclass_classify test.txt learned_svm output.txt`
4. Get stats `ruby stats.rb`