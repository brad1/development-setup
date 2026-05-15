%{
#include <stdio.h>
#include "statemachine.hh"
%}

%%
State			return STATETOK;
Machine			return MACHINETOK;
Inputs			return INPUTSTOK;
Outputs			return OUTPUTSTOK;
States			return STATESTOK;
Initial			return INITIALTOK;
Transitions		return TRANSITIONSTOK;
[a-zA-Z0-9][a-zA-Z0-9]*[,]* yylval = strdup(yytext); return WORD;
\"                      return QUOTE;
\{                      return OBRACE;
\}                      return EBRACE;
;                       return SEMICOLON;
\(			return OPAREN;
\)			return EPAREN;
,			return COMMA;
\/			return SLASH;
\=			return EQUALS;
\n                      /* ignore EOL */;
[ \t]+                  /* ignore whitespace */;
%%
