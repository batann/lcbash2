CXX = g++
CXXFLAGS = -std=c++17 -Wall -O2

TARGET = main

all: $(TARGET)

main: src/main.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^

clean:
	rm -f $(TARGET)

