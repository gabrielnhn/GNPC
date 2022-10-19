
/*
Autor: Bruno Müller Junior
Data: 08/2007
Editado por Gabriel Nascarella Hishida do Nascimento

* Tipos, protótipos e variáveis globais do compiler (via extern)
*/

%{


#include<stdio.h>
#include<string.h>

#include "compiler.h"
#include "compiler.tab.h"

//#define PRINT(STR) {};
#define PRINT(STR) printf("%s    # %s \n", STR, token);

int nl = 1;

%}

newline [\n]

discard [\t ]+

ident [a-zA-Z][a-zA-Z0-9]*

number [0-9]+

comment "(*".*"*)"

%%

{newline} {nl++;}

{discard}

{comment}

program { symbol  = symb_program;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("program ");
          return PROGRAM;
 }

var      { symbol = symb_var;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("var  ");
          return VAR;
 }

begin { symbol = symb_begin;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("begin ");
          return T_BEGIN;
 }

end { symbol = symb_end;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT("end  ");
          return T_END;
 }

:= { symbol = symb_assignment;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" assignment  ");
          return ASSIGNMENT;
 }

\; { symbol = symb_semicolon;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" semicolon  ");
          return SEMICOLON;
 }

\: { symbol = symb_colon;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" colon ");
          return COLON;
 }

\, { symbol = symb_comma;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" comma  ");
          return COMMA;
 }


\. { symbol = symb_dot;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" dot  ");
          return DOT;
    }

\(  { symbol = symb_open_parenthesis;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" open_parenthesis  ");
          return OPEN_PARENTHESIS;
    }

\)  { symbol = symb_close_parenthesis;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" close_parenthesis ");
          return CLOSE_PARENTHESIS;
 }

{ident} { symbol = symb_identifier;
          strncpy (token, yytext, TOKEN_SIZE);
          PRINT(" ident  ");
          return IDENT;
        }


%%
