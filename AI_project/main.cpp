// this file show the example for how to load the model and predict

#include "AI_filter.hpp"
using namespace std;

int main() {
	string sql_statement = "select name from users;";

	// turn on the logging output when loading model
	// const auto model = fdeep::load_model("./python_AI/sql_injection_detecting.json");

	// silence the loggging output when loading model
	// "load_model()" is a function in "frugally-deep" function
	// github:https://github.com/Dobiasd/frugally-deep
	const auto model = fdeep::load_model("./python_AI/sql_injection_detecting.json", true, fdeep::dev_null_logger);

	const string python_folder_name = "./";							 // folder name where python file in
	const string python_file_name = "customized_python_function";    // python file name
	const string python_function_name = "vectorizer";                // python function in the file

	vector<float> data = data_preprocess(python_folder_name, python_file_name, python_function_name, sql_statement);

	const auto result = model.predict(
        {
            fdeep::tensor(fdeep::tensor_shape(static_cast<std::size_t>(data.size())),data)
        }
    );
	
	//std::cout << fdeep::show_tensors(result) << std::endl;
    const std::vector<float> result_vec = result.front().to_vector();

	cout << result_vec[0] << endl;

	return 0;
}