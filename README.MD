# Instructions
1. Add svm binaries to project folder (https://www.cs.cornell.edu/people/tj/svm_light/svm_multiclass.html)
2. Run part2.rb in console i.e.

	ruby part2.rb
3. Train with a c-value (1.0 here)

	./svm_multiclass_learn -c 1.0 training.txt learned_svm
4. Classify

	./svm_multiclass_classify training.txt learned_svm output.txt