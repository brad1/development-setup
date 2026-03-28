CXX ?= g++
CXXFLAGS ?= -std=c++17 -Wall -Wextra -Wpedantic

TARGET := cpp_demo
SOURCES := main.cpp $(wildcard modules/*.cpp)
OBJECTS := $(SOURCES:.cpp=.o)

.PHONY: all clean run

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJECTS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(TARGET) $(OBJECTS)
