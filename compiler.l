
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
          strncpy (token, yytext, TAM_TOKEN);
          PRINT("program ");
          return PROGRAM;
 }

var      { symbol = symb_var;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT("var  ");
          return VAR;
 }

begin { symbol = symb_begin;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT("begin ");
          return T_BEGIN;
 }

end { symbol = symb_end;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT("end  ");
          return T_END;
 }

:= { symbol = symb_assignment;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT(" assignment  ");
          return ASSIGNMENT;
 }

\; { symbol = symb_semicolon;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT(" semicolon  ");
          return SEMICOLON;
 }

\: { symbol = symb_colon;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT(" colon ");
          return COLON;
 }

\, { symbol = symb_comma;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT(" comma  ");
          return COMMA;
 }


\. { symbol = symb_dot;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT(" dot  ");
          return DOT;
    }

\(  { symbol = symb_open_parenthesis;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT(" open_parenthesis  ");
          return OPEN_PARENTHESIS;
    }

\)  { symbol = symb_close_parenthesis;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT(" close_parenthesis ");
          return CLOSE_PARENTHESIS;
 }

{ident} { symbol = symb_identifier;
          strncpy (token, yytext, TAM_TOKEN);
          PRINT(" ident  ");
          return IDENT;
        }


%%
