
// Testar se funciona corretamente o empilhamento de par�metros
// passados por valor ou por refer�ncia.


%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compiler.h"

char string_buffer[69];

int num_vars;
symbol_table table;
stack_t e_stack, f_stack, t_stack, label_stack;
int label_count = -1;
int list_size = 0;
int level = 0;
int offset = 0;
int list_type = -1;
int left_side_level = -1;
int left_side_offset = -1;
int left_side_type = -1;
int left_side_index = -1;
int return_label = -1;

int comparison;

int symbol_index;

%}

%token PROGRAM OPEN_PARENTHESIS CLOSE_PARENTHESIS
%token COMMA SEMICOLON COLON DOT
%token T_BEGIN T_END VAR IDENT ASSIGNMENT
%token LABEL TYPE ARRAY OF PROCEDURE
%token GOTO IF THEN ELSE WHILE DO
%token OR AND NOT DIV ASTERISK PLUS MINUS
%token EQUAL DIFFERENT LESS_OR_EQUAL LESS MORE_OR_EQUAL MORE
%token NUMBER

%%

program    :{
             generate_code (NULL, "INPP");
             }
             PROGRAM IDENT
             OPEN_PARENTHESIS idents_list CLOSE_PARENTHESIS SEMICOLON
             block DOT {
             remove_symbols_from_table(&table, table.size);
             sprintf(string_buffer, "DMEM %d", offset);
             generate_code(NULL, string_buffer);


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
                  sprintf(string_buffer, "AMEM %d", list_size);
                  generate_code(NULL, string_buffer);


                  /* SET VARIABLE TYPES */
                  list_type = get_type(token);
                  if (not list_type)
                  {
                     sprintf(string_buffer, "Unsupported type '%s'", token);
                     print_error(string_buffer);
                  }

                  update_symbol_table_type(&table, list_size, list_type);
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

commands: commands command | command;

command: assignment | compound_command | loop;

loop: WHILE
{
   label_count += 1;
   sprintf(string_buffer, "R%.2d", label_count);
   generate_code(string_buffer, "NADA");
   stack_push(&label_stack, label_count);
   
   
   label_count += 1;
}
boolean_expr
{
   sprintf(string_buffer, "DSVF R%.2d", label_count);
   generate_code(NULL, string_buffer);
}
DO command
{
	stack_pop(&label_stack, &return_label);
   sprintf(string_buffer, "DSVS R%.2d", return_label);
   generate_code(NULL, string_buffer);

	sprintf(string_buffer, "R%.2d", return_label + 1);
   generate_code(string_buffer, "NADA");
};


/* ASSIGNMENT */

assignment: IDENT
{
   assert_symbol_exists(&table, token);
   search_symbol_table(&table, token, &left_side_level, &left_side_offset);
   search_symbol_table_index(&table, token, &left_side_index);

}
ASSIGNMENT boolean_expr SEMICOLON
{
   int expr_type;
   stack_pop(&e_stack, &expr_type);
   left_side_type = table.stack[left_side_index].type;

   if (left_side_type != expr_type)
      print_error("LS Type Error");


   sprintf(string_buffer, "ARMZ %d %d", left_side_level, left_side_offset);
   generate_code(NULL, string_buffer);
}
;

/* BOOLEAN EXPRESSIONS */

boolean_expr: arithmetic_expr 

|boolean_expr EQUAL arithmetic_expr
{
   int type = assert_equal_types(&e_stack, &e_stack);
   generate_code(NULL, "CMIG"); 
   stack_push(&e_stack, BOOL_TYPE);
}
|boolean_expr DIFFERENT arithmetic_expr
{
   int type = assert_equal_types(&e_stack, &e_stack);
   generate_code(NULL, "CMDG"); 
   stack_push(&e_stack, BOOL_TYPE);
}
|boolean_expr LESS_OR_EQUAL arithmetic_expr
{
   int type = assert_equal_types(&e_stack, &e_stack);
   generate_code(NULL, "CMEG"); 
   stack_push(&e_stack, BOOL_TYPE);
}
|boolean_expr LESS arithmetic_expr
{
   int type = assert_equal_types(&e_stack, &e_stack);
   generate_code(NULL, "CMME"); 
   stack_push(&e_stack, BOOL_TYPE);
}
|boolean_expr MORE_OR_EQUAL arithmetic_expr
{
   int type = assert_equal_types(&e_stack, &e_stack);
   generate_code(NULL, "CMAG"); 
   stack_push(&e_stack, BOOL_TYPE);
}
|boolean_expr MORE arithmetic_expr
{
   int type = assert_equal_types(&e_stack, &e_stack);
   generate_code(NULL, "CMMA"); 
   stack_push(&e_stack, BOOL_TYPE);
};

/* ARITHMETIC EXPRESSIONS */


arithmetic_expr: E;

E: E PLUS T 
{
   int type = assert_equal_types(&e_stack, &t_stack);
   generate_code(NULL, "SOMA"); 
   stack_push(&e_stack, type);
}  
| E MINUS T 
{
   int type = assert_equal_types(&e_stack, &t_stack);
   generate_code(NULL, "SUBT");
   stack_push(&e_stack, type);
}
| T
{
   int type;
   stack_pop(&t_stack, &type);
   stack_push(&e_stack, type);
};

T: T ASTERISK F 
{
   int type = assert_equal_types(&t_stack, &f_stack);
   generate_code(NULL, "MULT");
   stack_push(&t_stack, type);
}
| T DIV F 
{
   int type =  assert_equal_types(&t_stack, &f_stack);
   generate_code(NULL, "DIVI");
   stack_push(&t_stack, type);
}
| F
{
   int type;
   stack_pop(&f_stack, &type);
   stack_push(&t_stack, type);

};

F: NUMBER
   {
      printf("\nLOAD NUMBER %s\n", token);
      // stack type
      stack_push(&f_stack, INTEGER_TYPE);

      // load constant
      sprintf(string_buffer, "CRCT %s", token);
      generate_code(NULL, string_buffer);
   } 
   |IDENT
   {
      assert_symbol_exists(&table, token);

      printf("\nLOAD VARIABLE %s\n", token);

      // stack type
      search_symbol_table_index(&table, token, &symbol_index);
      int type = table.stack[symbol_index].type;
      stack_push(&f_stack, type);

      // load value
      int level, offset;
      search_symbol_table(&table, token, &level, &offset);
      sprintf(string_buffer, "CRVL %d %d", level, offset);
      generate_code(NULL, string_buffer);
   }

   | OPEN_PARENTHESIS boolean_expr CLOSE_PARENTHESIS
   {
      int type;
      stack_pop(&e_stack, &type);
      stack_push(&f_stack, type);
   }
;

%%

/* MAIN */



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
   init_stack(&e_stack);
   init_stack(&t_stack);
   init_stack(&f_stack);
   init_stack(&label_stack);


   yyin=fp;
   yyparse();

   return 0;
}
