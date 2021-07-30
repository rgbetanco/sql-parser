CC = g++
IN = main.cpp
OUT = main.out
SHELL_SCRIPT = python_AI/h5_to_json.sh


all :
	sh $(SHELL_SCRIPT)
	$(CC) $(IN) -o $(OUT) -lpython3.7m
	@echo "\e[92mcompile $(IN) success!\033[0m"

clean : 
	rm -rf $(OUT)
