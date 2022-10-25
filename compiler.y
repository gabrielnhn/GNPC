
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compiler.h"

int num_vars;

%}

%token PROGRAM OPEN_PARENTHESIS CLOSE_PARENTHESIS
%token COMMA SEMICOLON COLON DOT
%token T_BEGIN T_END VAR IDENT ASSIGNMENT
%token LABEL TYPE ARRAY OF PROCEDURE
%token GOTO IF THEN ELSE WHILE DO
%token OR AND NOT DIV ASTERISK PLUS MINUS

%%

program    :{
             generate_code (NULL, "INPP");
             }
             PROGRAM IDENT
             OPEN_PARENTHESIS idents_list CLOSE_PARENTHESIS SEMICOLON
             block DOT {
             generate_code (NULL, "PARA");
             }
;

block       :
              declaring_vars_block
              {
              }

              compound_command
              ;




declaring_vars_block:  var
;


var         : { } VAR declare_vars
            |
;

declare_vars: declare_vars declare_var
            | declare_var
;

declare_var : { }
              id_var_list COLON
              tipo
              { /* AMEM */
              }
              SEMICOLON
;

tipo        : IDENT
;

id_var_list: id_var_list COMMA IDENT
              { /* insere ultima vars na tabela de simbolos */ }
            | IDENT { /* insere vars na tabela de simbolos */}
;

idents_list: idents_list COMMA IDENT
            | IDENT
;


compound_command: T_BEGIN commands T_END

commands:
;


%%

int main (int argc, char** argv) {
   FILE* fp;
   extern FILE* yyin;

   if (argc<2 || argc>2) {
         printf("usage compiler <arq>a %d\n", argc);
         return(-1);
      }

   fp=fopen (argv[1], "r");
   if (fp == NULL) {
      printf("usage compiler <arq>b\n");
      return(-1);
   }


/* -------------------------------------------------------------------
 *  Inicia a Tabela de Simbolos
 * ------------------------------------------------------------------- */

   yyin=fp;
   yyparse();

   return 0;
}
