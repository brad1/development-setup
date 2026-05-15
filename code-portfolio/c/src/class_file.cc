#include "class_file.h"

//default constructor
StateMachine::StateMachine()
{
}

//set input list
void StateMachine::setInputList(list<string>* newList)
{
  inputList = newList;
  return;
}

//set output list
void StateMachine::setOutputList(list<string>* newList)
{
  outputList = newList;
  return;
}

//set state list
void StateMachine::setStateList(list<string>* newList)
{
  stateList = newList;
  return;
}

//set initial state
void StateMachine::setInitialState(string newState)
{
  initialState = newState;
  currentState = newState;
  return;
}

string StateMachine::getInitialState() {
   return initialState;
}

//add transition to internal list
void StateMachine::addTransition(transition* newTrans)
{
  transList.push_back(newTrans);
  return;
}

//set name of state machine
void StateMachine::setName(string newName)
{
  name = newName;
  return;
}

//set name of state machine
string StateMachine::getName()
{
   return name;
}

string StateMachine::update(string input) {
  list<transition*>::iterator it;
  for(it = transList.begin(); it != transList.end(); it++) {
    if( (*it)->initState == currentState && (*it)->input == input ) {
      currentState = (*it)->finalState;
      return (*it)->output;
    }
  }
  return "";
}

list<string> *StateMachine::getInputs() {
  return inputList;	
}

list<string> *StateMachine::getOutputs() {
  return outputList;	
}

list<string> *StateMachine::getStates() {
  return stateList;	
}

string StateMachine::getCurrentState() {
  return currentState;
}

void StateMachine::setState( string state) {
  currentState = state;
}




















