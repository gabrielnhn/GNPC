
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
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("program ");
          return PROGRAM;
 }

label      { symbol = symb_label;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("label  ");
          return LABEL;
 }

type      { symbol = symb_type;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("type  ");
          return TYPE;
 }

array      { symbol = symb_array;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("array  ");
          return ARRAY;
 }

of      { symbol = symb_of;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("of  ");
          return OF;
 }

var      { symbol = symb_var;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("var  ");
          return VAR;
 }

procedure      { symbol = symb_procedure;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("procedure  ");
          return PROCEDURE;
 }

begin { symbol = symb_begin;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("begin ");
          return T_BEGIN;
 }

end { symbol = symb_end;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("end  ");
          return T_END;
 }

goto      { symbol = symb_goto;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("goto  ");
          return GOTO;
 }

if      { symbol = symb_if;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("if  ");
          return IF;
 }

then      { symbol = symb_then;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("then  ");
          return THEN;
 }

else      { symbol = symb_else;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("else  ");
          return ELSE;
 }

while      { symbol = symb_while;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("while  ");
          return WHILE;
 }

do      { symbol = symb_do;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("do  ");
          return DO;
 }

or      { symbol = symb_or;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("or  ");
          return OR;
 }

and      { symbol = symb_and;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("and  ");
          return AND;
 }

not      { symbol = symb_not;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("not  ");
          return NOT;
 }

div      { symbol = symb_div;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("div  ");
          return DIV;
 }

read      { symbol = symb_read;
        strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

        PRINT("read  ");
        return READ;
}

write      { symbol = symb_write;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("write  ");
          return WRITE;
 }

\*     { symbol = symb_asterisk;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("asterisk  ");
          return ASTERISK;
 }

\+      { symbol = symb_plus;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("plus  ");
          return PLUS;
 }

\-      { symbol = symb_minus;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("minus  ");
          return MINUS;
 }

\:= { symbol = symb_assignment;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT(" assignment  ");
          return ASSIGNMENT;
 }

\; { symbol = symb_semicolon;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT(" semicolon  ");
          return SEMICOLON;
 }

\: { symbol = symb_colon;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT(" colon ");
          return COLON;
 }

\, { symbol = symb_comma;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT(" comma  ");
          return COMMA;
 }


\. { symbol = symb_dot;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT(" dot  ");
          return DOT;
    }

\(  { symbol = symb_open_parenthesis;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT(" open_parenthesis  ");
          return OPEN_PARENTHESIS;
    }

\)  { symbol = symb_close_parenthesis;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT(" close_parenthesis ");
          return CLOSE_PARENTHESIS;
 }

\=  { symbol = symb_equal;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("EQUAL  ");
          return EQUAL;
 }

\<>  { symbol = symb_different;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("DIFFERENT  ");
          return DIFFERENT;
 }

\<=  { symbol = symb_less_or_equal;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("LESS_OR_EQUAL  ");
          return LESS_OR_EQUAL;
 }

\<  { symbol = symb_less;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("LESS  ");
          return LESS;
 }

\>=  { symbol = symb_more_or_equal;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("MORE_OR_EQUAL  ");
          return MORE_OR_EQUAL;
 }

\>  { symbol = symb_more;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("MORE  ");
          return MORE;
 }

{ident} { symbol = symb_identifier;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT(" ident  ");
          return IDENT;
        }

{number}      { symbol = symb_number;
          strncpy (token, yytext, TOKEN_SIZE);
          strncpy (yylval.text, yytext, TOKEN_SIZE);

          PRINT("number  ");
          return NUMBER;
 }


%%
