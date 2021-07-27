
#include <python3.7m/Python.h>
#include <stdio.h>
#include "pyhelper.hpp"

int main() {
    printf("start cpp function\n");
     
    CPyInstance hInstance;
     
    PyObject * sys = PyImport_ImportModule("sys");
    PyObject * path = PyObject_GetAttrString(sys, "path");
    PyList_Append(path, PyUnicode_FromString("."));
     
    PyObject * ModuleString = PyUnicode_FromString((char*) "test_1");
    PyObject * Module = PyImport_Import(ModuleString);

    if(Module)
	{
		CPyObject pFunc = PyObject_GetAttrString(Module, "getInteger");
		if(pFunc && PyCallable_Check(pFunc))
		{
			CPyObject pValue = PyObject_CallObject(pFunc, NULL);

			printf("C: getInteger() = %ld\n", PyLong_AsLong(pValue));
		}
		else
		{
			printf("ERROR: function getInteger()\n");
		}

	}
	else
	{
		printf("ERROR: Module not imported\n");
	}
    // PyObject * Dict = PyModule_GetDict(Module);
    // PyObject * Func = PyDict_GetItemString(Dict, "python_test");
    // PyObject * Result = PyObject_CallObject(Func, NULL);
     

}