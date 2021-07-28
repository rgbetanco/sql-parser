#ifndef AI_FILTER_HPP
#define AI_FILTER_HPP
#pragma once

#include <string>
#include <iostream>
#include <vector>

#include "pyhelper.hpp"

// determine if the statement is a sql injection
bool is_sql_injection(std::string sql_statement);

// use python function to preprocess the data
std::vector<float> data_preprocess(std::string python_file, std::string python_function, std::string sql_statement); 

// convert the list to the float vector because the package that convert keras into C++ doesn't support the vector of integer
std::vector<float> python_list_to_vector(CPyObject python_list); 


bool is_sql_injection(std::string sql_statement){
    std::string python_file_name = "customized_python_function";
	std::string python_function_name = "vectorizer";
    std::vector<float> data;
	
	data = data_preprocess(python_file_name, python_function_name, sql_statement);
    std::cout << data.size() << std::endl;
    return 1;
}

std::vector<float> data_preprocess(std::string python_file_name, std::string python_function_name, std::string sql_statement){
    CPyInstance hInstance;

	// this area is necessary
    CPyObject sys = PyImport_ImportModule("sys");
    CPyObject path = PyObject_GetAttrString(sys, "path");
    PyList_Append(path, PyUnicode_FromString("."));
     
    CPyObject pName = PyUnicode_FromString(python_file_name.c_str());	//import python file
	CPyObject Module = PyImport_Import(pName);

    std::vector<float> data;

    if(Module)
	{
		CPyObject pFunc = PyObject_GetAttrString(Module, python_function_name.c_str());		//get function in that python file
		if(pFunc && PyCallable_Check(pFunc))
		{	
            CPyObject arglist = Py_BuildValue("(s)", sql_statement.c_str());	//build the argument of the function 
			CPyObject pValue = PyObject_CallObject(pFunc, arglist);     //pValue is a return value from python function
            if(PyList_Check(pValue)){
                data = python_list_to_vector(pValue);
            }
            else{
                std::cout << "Return value is not a python list" << std::endl;
            }
		}
		else{
            std::cout << "ERROR: function error" << std::endl;
		}

	}
	else{
        std::cout << "ERROR: Module not imported" << std::endl;
	}

    return data;
}

std::vector<float> python_list_to_vector(CPyObject python_list){
    int list_size = PyList_Size(python_list);
    std::vector<float> return_vector(list_size);
    CPyObject ptemp;
    double result;

    for(int i = 0; i < list_size; i++){
        ptemp = PyList_GetItem(python_list, i);
        result = PyFloat_AsDouble(ptemp);
        return_vector[i] = result;
    }
    return return_vector;
}

#endif