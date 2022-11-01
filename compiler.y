
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compiler.h"

char generate_code_buffer[69];

int num_vars;
symbol_table table;
int list_size = 0;
int level = 0;
int offset = 0;

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
             remove_symbols_from_table(&table, table.size);
             sprintf(generate_code_buffer, "DMEM %d", offset);
             generate_code(NULL, generate_code_buffer);


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

declare_var : { list_size = 0; }
              id_var_list
              COLON
              type
              { 
                  /* AMEM */
                  sprintf(generate_code_buffer, "AMEM %d", list_size);

                  generate_code(NULL, generate_code_buffer);

                  /* SET VARIABLE TYPES */
                  print_symbol_table(&table);
              }
              SEMICOLON
;

type        : IDENT
;

id_var_list: id_var_list COMMA IDENT
            { /* insere ultima vars na tabela de simbolos */
               
                insert_symbol_table(&table, level, offset, token);
                offset++;
                list_size++;
                
            }
            | IDENT
            { /* insere vars na tabela de simbolos */
              
                insert_symbol_table(&table, level, offset, token);
                offset++;
                list_size++;

            }
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
   
   init_symbol_table(&table);

   yyin=fp;
   yyparse();

   return 0;
}
