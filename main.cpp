#include "sql_statement_parser/y.tab.h"
#include "AI_project/AI_filter.hpp"

#include <string>
#include <iostream>
using namespace std;

int main(){
    const string sql_statement = "select name from users;";
    const string config_file = "./config/blocked_list.json";

    int parse_result = exec_parser(sql_statement.c_str(), config_file.c_str());
    
    if(parse_result == 0){    // parse success
        const auto model = fdeep::load_model("./AI_project/python_AI/sql_injection_detecting.json", true, fdeep::dev_null_logger);

        const string python_folder_name = "./AI_project";                // the folder name where python file in 
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
    }
    else{               // parse failed
        cout << "statement parse failed" << endl;
    }
}