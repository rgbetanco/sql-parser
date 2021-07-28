#include "AI_filter.hpp"
using namespace std;

int main() {
	string sql_statement = "select id from name;";
	is_sql_injection(sql_statement);
	return 0;
}