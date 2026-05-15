%{
#include <stdio.h>
#include <string.h>
#include <list>
#include <iostream>
#include <string>
#include "class_file.h"

//change type of value passed with token from int to char*
#define YYSTYPE char *

using namespace std;

//lists and vars, mostly pointers, used in main to populate StateMachine class instances
list<string> stringList;
list<string>* inputList;
list<string>* outputList;
list<string>* stateList;
string initialState;
transition* curTrans;
list<transition *> transList;
StateMachine* curMachine;
list<StateMachine *> machineList;

//this part needed since we are compiling c++ code
extern "C" 
{
  int yyparse(void);
  int yylex(void);
  void yyerror(const char *str)
  {
	  fprintf(stderr,"error: %s\n",str);
  }

  int yywrap()
  {
	  return 1;
  }
  void yyrestart(FILE*);
}



%}

%token EQUALS WORD FILENAME QUOTE OBRACE EBRACE SEMICOLON STATETOK MACHINETOK INPUTSTOK OUTPUTSTOK STATESTOK INITIALTOK TRANSITIONSTOK OPAREN EPAREN COMMA SLASH

%%

statemachines:
	    |
	    statemachines statemachine
	    ;

statemachine:
	STATETOK MACHINETOK WORD OBRACE inputset outputset stateset initialset transitionset EBRACE
	{
	  //set up instance of StateMachine class
	  curMachine = new StateMachine;
	  curMachine->setName($3);
	  //add inputs, outputs, states, initial
	  curMachine->setInputList(inputList);
	  curMachine->setOutputList(outputList);
	  curMachine->setStateList(stateList);
	  curMachine->setInitialState(initialState);
	  //add state transitions
	  while (!transList.empty())
	  {
	    curMachine->addTransition(transList.front());
	    transList.pop_front();
	  }
	  //add machine to collection
	  machineList.push_back(curMachine);
	};

inputset:
	INPUTSTOK EQUALS set SEMICOLON
	{
	  //populate input collection
	  inputList = new list<string>();
	  while (!stringList.empty())
	  {
	    inputList->push_back(stringList.front());
	    stringList.pop_front();
	  }
	};

outputset:
	OUTPUTSTOK EQUALS set SEMICOLON
	{
	  //populate output collection
	  outputList = new list<string>();
	  while (!stringList.empty())
	  {
	    outputList->push_back(stringList.front());
	    stringList.pop_front();
	  }
	};

stateset:
	STATESTOK EQUALS set SEMICOLON
	{
	  //populate state collection
	  stateList = new list<string>();
	  while (!stringList.empty())
	  {
	    stateList->push_back(stringList.front());
	    stringList.pop_front();
	  }
	};

initialset:
	INITIALTOK EQUALS set SEMICOLON
	{
	  //get initial state
	  initialState = stringList.front();
	  stringList.pop_front();
	};    

transitionset:
	STATETOK TRANSITIONSTOK transet SEMICOLON
	{
	  
	};
set:
      OBRACE words EBRACE

words:
	|
	words WORD
	{
	  //deal with commas (get rid of them)
	  string newString = string($2);
	  int len = strlen($2);
	  if (newString[len-1] == ',')
	  {
	    newString = newString.substr(0, len-1);
	  }
	  stringList.push_back(newString);
	};

transet:
	OBRACE tran commatrans EBRACE

commatrans:
	|
	commatrans commatran	
	;

commatran:
	COMMA tran 

tran:
	OPAREN WORD WORD SLASH WORD WORD EPAREN
	{
	  //create new transition struct, populate w/data, add to collection
	  curTrans = new transition;
	  int len = strlen($2);
	  curTrans->initState = string($2).substr(0, len-1); 
	  curTrans->input = string($3);
	  len = strlen($5);
	  curTrans->output = string($5).substr(0, len-1);
	  curTrans->finalState = string($6);
	  transList.push_back(curTrans);
	};




