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

	// "sql_injection_predict()" is "AI_filter.hpp"
	float predict = sql_injection_predict(model, sql_statement);
	
	cout << "predict : " << predict << endl;

	return 0;
}