#include <stdio.h>
#include <string.h>
#include <list>
#include <iostream>
#include <string>
#include <cstring>
#include <fstream>
#include "class_file.h"
#include <cstdlib>
#include <cmath>
#include <map>

// #define _DEBUG_

/* List of all state machines found by the parser */
extern list<StateMachine *> machineList;

extern "C" 
{
  int yyparse(void);
  int yylex(void);
  void yyerror(const char *str);
  int yywrap();
  void yyrestart(FILE*);
}

/* communication struct for file generation. */
struct fileGeneration {
    std::map<string, int> stateTable;
    std::map<string, int> inputTable;
    std::map<string, int> outputTable;
    
    ofstream file;
    string inputRequestString;
    string filename;
    string smname;
    string initialState;
    StateMachine *sm;
    string term;
};

/* generates a string os spaces for  */
string space( int length) {
    string retval = "";
    int i;
    for( i = 0; i < length; i++) {
        retval += " ";
    }
    return retval;
};

/* Identifies and states, inputs and outputs from the .sm files */
void buildSymbolTable( struct fileGeneration *params ) {
#ifdef _DEBUG_
    cout << "building sym tabe" << endl;
#endif
    int stateId = 0;
    int inputId = 0;
    int outputId = 0;
    map<string, int> & states = params->stateTable;
    map<string, int> & inputs = params->inputTable;
    map<string, int> & outputs = params->outputTable;
    string &request = params->inputRequestString;

#ifdef _DEBUG_
    cout << "assigning input symbols" << endl;
#endif
    string sep = "";
    request = "\"Provide input as ";
    list<string>::iterator ins = params->sm->getInputs()->begin(); 
    list<string>::iterator end = params->sm->getInputs()->end(); 
    for( ; ins != end; ins++ ) {
        stringstream inId;
        inId << inputId;
        request += (sep + inId.str() + " for " + *ins);
        sep = ", ";
        string idx = "INPUT_" + *ins;
        inputs[idx] = inputId++;
    }
    stringstream inId;
    inId << inputId;
    request += " or " + inId.str()  +  " when done\""; 

#ifdef _DEBUG_
    cout << "assigning output symbols" << endl;
#endif
    ins = params->sm->getOutputs()->begin();
    end = params->sm->getOutputs()->end();
    for( ; ins != end; ins++) {
        string idx = "OUTPUT_" + *ins;
        outputs[idx] = outputId++;
    }

#ifdef _DEBUG_
    cout << "assigning state symbols" << endl;
#endif
    ins = params->sm->getStates()->begin();
    end = params->sm->getStates()->end();
    for( ; ins != end; ins++ ) {
        string idx = "STATE_" + *ins;
        states[idx] = stateId++;
    }

    string &done = params->term;
    inputs[done] = inputId;
    params->initialState = "STATE_" + params->sm->getInitialState();
}
 
/* Writes the innermost part of the case-switch statements */
void writeStateTransition( string state, string input, struct fileGeneration *params, int depth ) {
#ifdef _DEBUG_
    cout << "writing a state transition" << endl;
#endif
    ofstream &file = params->file;
    string indent = space(4*depth);
    string tab = space(4);
    file << indent << "case " << input << ":" << endl;
    
    if( input == params->term ) {
        file << indent << tab << "std::cout << \"Simulation termination requested\" << endl;" << endl;
        file << indent << tab << "exit(0);" << endl;
    } else {
        file << indent << tab << "state = stateTransition[" << state << "][" << input << "];" << endl;
        file << indent << tab << "std::cout << \"Output : \" << output[" << state << "][" << input << "] << endl;" << endl;
    }
    file << indent << tab << "break;" << endl;
}

/* Writes the cases for matching the current state */
void writeStateCase( string state, struct fileGeneration *params, int depth ) {
#ifdef _DEBUG_
    cout << "writing a state case" << endl;
#endif
    map<string, int>::iterator it;
    map<string, int>::iterator start = params->inputTable.begin();
    map<string, int>::iterator end   = params->inputTable.end();
    ofstream &file = params->file;
    string indent = space(4*depth);
    string tab = space(4);

    file << indent << "case " << state << ":" << endl;
    file << indent << tab << "switch(input) {" << endl;
    for( it = start; it != end; it++ ) { // write inner cases
        writeStateTransition(state, it->first, params, depth + 2); 
    }
    file << indent << tab << tab << "default:" << endl;
    file << indent << tab << tab << tab << "std::cout << \"invalid input, \" << " + params->inputRequestString + " << endl;" << endl;
    file << indent << tab << tab << tab << "break;" << endl;
    file << indent << tab << "}" << endl;
    file << endl;
    file << indent << tab << "break;" << endl << endl;
}

/* Writes the UI loop for the current thread. */
void writeLoop(  struct fileGeneration *params, int depth ) {
#ifdef _DEBUG_
    cout << "writing infinite loop" << endl;
#endif
    std::map<string, int>::iterator it  = params->stateTable.begin(); 
    std::map<string, int>::iterator end = params->stateTable.end(); 
    ofstream &file = params->file;
    string indent = space(4*depth);
    string tab = space(4);

    file << indent << "std::cout << " << params->inputRequestString << " << endl;" << endl;
    file << indent << "std::cin >> input;" << endl;
    file << indent << "switch(state) {" << endl;
    
    
    for( ; it != end; it++ ) {
        writeStateCase( it->first, params, depth+1 );
    }
    file << indent << tab << "default:" << endl;
    file << indent << tab << tab << "std::cout << \"State machine is in an invalid state.\" << endl;" << endl;
    file << indent << tab << tab << "std::cout << \"reinitializing state machine ....\" << endl;" << endl;
    file << indent << tab << tab << "state = " << params->initialState << ";" << endl;
    file << indent << "}" << endl; // end first case statement
}

/* Writes the outputs that occur during state transitions */
void generateOutputs( struct fileGeneration *params, int depth ) {
#ifdef _DEBUG_
    cout << "writing the outputs" << endl;
#endif
    ofstream &file = params->file;
    string indent = space(4*depth);

    list<string>::iterator it; 
    list<string>::iterator start = params->sm->getStates()->begin(); 
    list<string>::iterator end   = params->sm->getStates()->end(); 
    string sep = indent;
    // iterate through all states
    for( it = start; it != end; it++ ) {
        params->sm->setState(*it);
        list<string>::iterator ins; 
        list<string>::iterator stat = params->sm->getInputs()->begin(); 
        list<string>::iterator ed   = params->sm->getInputs()->end(); 
        // log all valid transitions for each input
        file << sep << "{ ";
        sep = ",\n" + indent;
        string pre = "";
        for( ins = stat; ins != ed; ins++ ) {
            string output = params->sm->update(*ins);
            string nextState = params->sm->getCurrentState();
            if( output == "" ) {
                ;
            } else {
                file << pre << "OUTPUT_" << output; 
                pre = ", ";
            }
            params->sm->setState(*it);
        }
        file << " }";
    }
}

/* generates the code  to update the state of the machine. */
void generateNextStates( struct fileGeneration *params, int depth ) {
#ifdef _DEBUG_
    cout << "writing the nextStates" << endl;
#endif
    ofstream &file = params->file;
    string indent = space(4*depth);

    list<string>::iterator it; 
    list<string>::iterator start = params->sm->getStates()->begin(); 
    list<string>::iterator end   = params->sm->getStates()->end(); 
    string sep = indent;
    // iterate through all states
    for( it = start; it != end; it++ ) {
        params->sm->setState(*it);
        list<string>::iterator ins; 
        list<string>::iterator stat = params->sm->getInputs()->begin(); 
        list<string>::iterator ed   = params->sm->getInputs()->end(); 
        // log all valid transitions for each input
        file << sep << "{ ";
        sep = ",\n" + indent;
        string pre = "";
        for( ins = stat; ins != ed; ins++ ) {
            string output = params->sm->update(*ins);
            string nextState = params->sm->getCurrentState();
            if( output == "" ) {
                ;
            } else {
                file << pre << "STATE_" << nextState;
                pre = ", ";
            }
            params->sm->setState(*it);
        }
        file << " }";
    }
}

/* This writes code contained in the function that is passed to thread creation. */
void writeFunction( struct fileGeneration *params, int depth ) {
#ifdef _DEBUG_
    cout << "writing the function" << endl;
#endif
    ofstream &file = params->file;
    string indent = space(4*depth);
    
    // Convert dimensions to string format 
    stringstream streamStates;
    streamStates << params->sm->getStates()->size();
    stringstream streamInputs;
    streamInputs << params->sm->getInputs()->size();

    string strNumStates = streamStates.str();
    string strNumInputs = streamInputs.str();

    file << indent << "int state = " << params->initialState << ";"  << endl;
    file << indent << "int stateTransition[" << strNumStates << "][" << strNumInputs << "] = {" << endl;
    
    generateNextStates( params, depth+1);
    
    file << "};" << endl;

    // "iterate through again, this time";
    file << indent << "int output[" + strNumStates + "][" + strNumInputs + "] = {" << endl;

    generateOutputs( params, depth+1 );

    file << "};" << endl;
    
    file << indent << "int input;" << endl;
    file << indent << "while(1) {" << endl;
    writeLoop( params, depth + 1 );
    file << indent << "}" << endl;
}


/* This defines the routine for thread creation */
void writeThread( struct fileGeneration *params ) {
#ifdef _DEBUG_
    cout << "writing the thread" << endl;
#endif
    string &name = params->smname;
    ofstream &file = params->file;

    file << "void *" << name << "(void *args) {" << endl; 
    writeFunction( params, 1 );
    file << "}";
}

/* Writes the #defines statements for intput, output, and states. */
void writeSymbols(struct fileGeneration *params) {
#ifdef _DEBUG_
    cout << "writing the symbols" << endl;
#endif
    ofstream &file = params->file;
    map<string, int>::const_iterator it;

    file << "#include " << "<iostream>" << endl;
    file << "#include " << "<cstdlib>" << endl;
    file << "using namespace::std;" << endl;

    // #define inputs
    map<string, int>::const_iterator start = params->inputTable.begin();
    map<string, int>::const_iterator end   = params->inputTable.end();
    for( it = start; it != end; ++it ) {
        file << "#define " << it->first << " " << it->second << endl;
    }

    // #define outputs
    file << endl;
    start = params->outputTable.begin();
    end   = params->outputTable.end();
    for( it = start; it != end; ++it ) {
        file << "#define " << it->first << " " << it->second << endl;
    }

    // #define states
    file << endl;
    start = params->stateTable.begin();
    end   = params->stateTable.end();
    for( it = start; it != end; ++it ) {
        file << "#define " << it->first << " " << it->second << endl;
    }
    file << endl;
}

/* Write the contents of the c file that simulates one state machine. */
void generateCfile( StateMachine* sm ) {
#ifdef _DEBUG_
    cout << "generating a c file" << endl;
#endif
    struct fileGeneration fg;
    fg.file.open( (sm->getName() + ".cc").c_str() );
    fg.smname = sm->getName();
    fg.sm = sm;
    fg.initialState = "STATE_" + sm->getInitialState();
    fg.term = "__MT_GENERATE_SM_DONE__";

    buildSymbolTable( &fg );
    writeSymbols( &fg );
    writeThread( &fg );
    fg.file.close();
}

/* Parses the files given on the command-line */
void parseFiles( int argc, char **argv) {
#ifdef _DEBUG_
    cout << "parsing files" << endl;
#endif
	  FILE * inputFile;
      bool fileSkipped = false;
      int numFiles = atoi(argv[1]);
      int i = 2;
      if( numFiles > argc-2 ) {
          cout << "Not enough filenames given" << endl;
          exit(1);
      }
      while( i < numFiles+2)
	  {
	    inputFile = fopen(argv[i], "r");
	    if( inputFile != NULL ) {
          //use this file for input to yyparse
  	      yyrestart(inputFile);
  	      //parse the statemachines
	      yyparse();
	      fclose(inputFile);
        } else {
            fileSkipped = true;
        }
        i++;
	  }

      if( fileSkipped ) {
          cout << "Warning: one or more of the files could not be opened and was skipped." << endl;
      }
}

/* This writes the main method that creates all threads. */
void writeMain(ofstream &file, int threadCount, list<string> threadNames) {
    list<string>::iterator it  = threadNames.begin();
    list<string>::iterator end = threadNames.end();
    stringstream numThread;
    numThread << threadCount;
    string numThreads = numThread.str();
    file << "#include <pthread.h>" << endl;

    // Method definitions for thred creation.
    for( ; it != end; it++) {
    file << "void *" << *it << "(void *);" << endl; 
    }
    file << endl;
    file << "int main() {" << endl;
    file << "    pthread_t threads[" << numThreads << "];" << endl;
    int i = 0;
    it  = threadNames.begin();

    // thread creation for each state machine
    for( ; it != end; it++) {
        stringstream ss;
        ss << i++;
    file << "    pthread_create( &threads[" << ss.str() << "], NULL, " << *it << ", NULL );" << endl;
    }

    // wait for all machines to finish running
    for( i = 0; i < threadCount; i++ ) {
        stringstream ss;
        ss << i;
    file << "    pthread_join( threads[" << ss.str() << "], NULL);" << endl;
    }
    file << "    return 0;" << endl;
    file << "}" << endl;
}

/* Writes the makefile that is used to compile the generated code. */
void buildMakefile( ofstream &file, list<string> files  ) {
    file << "all:" << endl;
    file << "\tg++ -O3 -Wall -lpthread stateMachine.cpp ";
    list<string>::iterator it  = files.begin();
    list<string>::iterator end = files.end();
    for( ; it != end; it++) {
        file << *it << ".cc ";
    }

    file << "-o RunStateMachines" << endl;
}

/* Entry point for the code generater. */
int main(int argc, char **argv)
{
#ifdef _DEBUG_
    cout << "main" << endl;
#endif
    if( argc > 1) 
	{
        parseFiles( argc, argv );
       
        list<string> stateNames;
        list<StateMachine*>::iterator it;
        list<StateMachine*>::iterator start = machineList.begin();
        list<StateMachine*>::iterator end   = machineList.end();
        int numSMs = 0;
        
	// generate a source file for every state machine
        for(it = start; it != end; it++) {
            stateNames.push_back((*it)->getName());
            generateCfile( *it );
            numSMs++;
        }
        
	// Main method, runns all threads.
        ofstream file;
        file.open("stateMachine.cpp");
        writeMain( file, numSMs, stateNames );
        file.close();

	// Writes makefile for the generated c code.
        ofstream makefile;
        makefile.open("generate");
        buildMakefile( makefile, stateNames );
        makefile.close();
	}
};

