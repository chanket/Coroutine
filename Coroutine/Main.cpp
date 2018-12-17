#include <iostream>
#include <vector>
#include "Context.h"

Context context_main = 0;
Context context_raii = 0;
Context context_deepcall = 0;

class test_vector {
public:
	test_vector(size_t size) {
		data = new unsigned char[size];
		std::cout << "    ==== The vector's constructor was called. ====" << std::endl;
	}

	~test_vector() {
		if (data == nullptr) {
			std::cout << "    ==== The vector's deconstructor was called repeatedly! ====" << std::endl;
		}
		else {
			delete[] data;
			data = nullptr;
			std::cout << "    ==== The vector's deconstructor was called. ====" << std::endl;
		}
	}

private:
	void * data;
};

int test_raii() {
	{
		test_vector data(8 * 1024 * 1024);
		context_raii = SaveContext();

		if (!context_raii->Resumed) {
			//Context saved
			std::cout << "    >> I left a vector here and will have a break..." << std::endl;
			ResumeContext(context_main);
		}
		else {
			//Context resumed
			std::cout << "    >> I go back to clean the vector..." << std::endl;

		}
	}

	return 0;
}

int test_deepcall(int depth = 1) {
	for (int i = 0; i < depth; i++) std::cout << "    ";
	std::cout << "Deep function called" << std::endl;

	int retval;
	if (depth < 8) {
		retval = test_deepcall(depth + 1);
	}
	else {
		retval = 0;
		context_deepcall = SaveContext();
		if (!context_deepcall->Resumed) {
			//Context saved
			for (int i = 0; i < depth; i++) std::cout << "    ";
			std::cout << "    >> I am deep enough and will have a break..." << std::endl;

			ResumeContext(context_main);
		}
		else {
			//Context resumed
			for (int i = 0; i < depth; i++) std::cout << "    ";
			std::cout << "    >> I am back now and will return one by one..." << std::endl;
		}
	}

	for (int i = 0; i < depth; i++) std::cout << "    ";
	std::cout << "Deep function returned" << std::endl;

	return retval;
}

int main() {
	context_main = SaveContext();
	/*
		The `context_main` is saved here.
		I can call `ResumeContext(context_main)` at any time, and my program would immediately return here.
		Therefore, the following code may be executed for MORE THAN ONCE.

		The field `context_main->Resumed` can be used to tell HOW MANY TIMES this context has been resumed.
		It is 0 right after `SaveContext()`, and will increase by 1 every time ResumeContext(context_main) was called.

		When a `context_main` will never be used, call `DestroyContext(context_main)` to free the memory it used.
		You can also use your own malloc/free implementations.
	*/

	if (context_main->Resumed == 0) {
		std::cout << "test_raii starting" << std::endl;
		test_raii();				//Next stop: context_main->Resumed == 1
		std::cout << "test_raii finished" << std::endl;
		DestroyContext(context_raii);
		std::cout << std::endl << std::endl;

		std::cout << "test_deepcall starting" << std::endl;
		test_deepcall();			//Next stop: context_main->Resumed == 2
		std::cout << "test_deepcall finished" << std::endl;
		DestroyContext(context_deepcall);
		std::cout << std::endl << std::endl;

		std::cout << "test_mix starting" << std::endl;
		std::cout << "test_raii starting" << std::endl;
		test_raii();				//Next stop: context_main->Resumed == 3
		std::cout << "test_raii finished" << std::endl;
		DestroyContext(context_raii);
		std::cout << "test_deepcall resuming" << std::endl;
		ResumeContext(context_deepcall);	

		//It has been resumed above, and the following will code never be executed
		std::terminate();
	}
	else if (context_main->Resumed == 1){
		//Context resumed for the 1st time
		std::cout << "test_raii resuming" << std::endl;
		ResumeContext(context_raii);

		//It has been resumed above, and the following will code never be executed
		std::terminate();
	}
	else if (context_main->Resumed == 2) {
		//Context resumed for the 2nd time
		std::cout << "test_deepcall resuming" << std::endl;
		ResumeContext(context_deepcall);

		//It has been resumed above, and the following will code never be executed
		std::terminate();
	}
	else if (context_main->Resumed == 3) {
		//Context resumed for the 3rd time
		std::cout << "test_deepcall starting" << std::endl;
		test_deepcall();			//Next stop: context_main->Resumed == 4
		std::cout << "test_deepcall finished" << std::endl;
		DestroyContext(context_deepcall);
		std::cout << "test_mix finished" << std::endl;
		std::cout << std::endl << std::endl;

		//Here is the only way out
	}
	else if (context_main->Resumed == 4) {
		//Context resumed for the 4th time
		std::cout << "test_raii resuming" << std::endl;
		ResumeContext(context_raii);

		//It has been resumed above, and the following will code never be executed
		std::terminate();
	}
	else {
		std::terminate();
	}

	std::cout << "All tests have been run" << std::endl;
	DestroyContext(context_main);
	std::cout << std::endl << std::endl;
	return 0;
}