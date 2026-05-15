#include <stdio.h>
#include <string.h>
#include <list>
#include <iostream>
#include <string>
#include <fstream>
#include <sstream>

using namespace std;

//struct for state transitions
struct transition {
  string initState;
  string input;
  string output;
  string finalState;
};

//class that contains everything about a parsed state machine
class StateMachine {
  public:
    StateMachine();
    void setInputList(list<string>* newList);
    void setOutputList(list<string>* newList);
    void setStateList(list<string>* newList);
    void setInitialState(string newState);
    void addTransition(transition* newTrans);
    void setName(string newName);
    void setState( string state);
    string getName(void);
    string update(string input);
    list<string> *getInputs();
    list<string> *getOutputs();
    list<string> *getStates();
    string getInitialState();
    string getCurrentState();
    
  private:
    list<string>* inputList;
    list<string>* outputList;
    list<string>* stateList;
    string initialState;
    list<transition *> transList;
    string name;
    string currentState;
};
