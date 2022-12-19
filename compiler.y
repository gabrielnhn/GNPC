%{
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include "compiler.h"

char string_buffer[69];
char string_buffer2[69];
symbol_table table;
stack_t e_stack, f_stack, t_stack, label_stack, proc_stack;

int num_vars, comparison, symbol_index;

int label_count = -1;
int list_size = 0;
int param_count;
int level = 0;
int offset = 0;
int list_type = -1;
int left_side_level = -1;
int left_side_offset = -1;
int left_side_type = -1;
int left_side_index = -1;
int return_label = -1;

int read_level = -1;
int read_offset = -1;

int var_category = SIMPLE_VAR_CATEGORY;
bool by_reference;
int proc_index;

int* proc_types;
int* proc_byrefs;
int proc_num_params;
int parsed_params;



%}

%union
{
    char text[TOKEN_SIZE];
    int ival;
    double dub;
};

%token PROGRAM OPEN_PARENTHESIS CLOSE_PARENTHESIS
%token COMMA SEMICOLON COLON DOT
%token T_BEGIN T_END VAR IDENT ASSIGNMENT
%token LABEL TYPE ARRAY OF PROCEDURE
%token GOTO IF THEN ELSE WHILE DO
%token OR AND NOT DIV ASTERISK PLUS MINUS
%token EQUAL DIFFERENT LESS_OR_EQUAL LESS MORE_OR_EQUAL MORE
%token NUMBER READ WRITE

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE
%define parse.error verbose
%define parse.assert true
%define parse.lac none
%define lr.default-reduction consistent


%%

program:
    {
        generate_code (NULL, "INPP");
    }
    PROGRAM IDENT OPEN_PARENTHESIS idents_list CLOSE_PARENTHESIS SEMICOLON
    block DOT
    {
        remove_symbols_from_table(&table, table.size);
        sprintf(string_buffer, "DMEM %d", offset);
        generate_code(NULL, string_buffer);
        generate_code (NULL, "PARA");
    }
;

block:
    declaring_vars_block declaring_procedures_block compound_command;

/* VARIABLE DECLARATION */

declaring_vars_block:
    VAR declare_vars | %empty ;

declare_vars:
    declare_vars declare_var | declare_var;

declare_var:
    {list_size = 0;}
    id_simple_var_list COLON type
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

type: IDENT;

id_simple_var_list:
    id_simple_var_list COMMA IDENT
    { /* last symbol insert */
        
        insert_symbol_table_simple_var(&table, level, offset, token);
        offset++;
        list_size++;
        
    }
    | IDENT
    { /* first to penultimate symbol insert */
        
        insert_symbol_table_simple_var(&table, level, offset, token);
        offset++;
        list_size++;
    }
;

idents_list: idents_list COMMA IDENT | IDENT;

/* PROCEDURES */

declaring_procedures_block: procedures | %empty  ;

procedures: procedures procedure_def | procedure_def;

procedure_def:
    PROCEDURE
    IDENT
    {
        level++;

        label_count++;
        
        // JUMP OUT OF PROCEDURE
        stack_push(&label_stack, label_count);
        sprintf(string_buffer, "DSVS R%.2d", label_count);
        generate_code(NULL, string_buffer);
        
        // ENTER PROCEDURE
        label_count++;  
        sprintf(string_buffer, "R%.2d", label_count);
        sprintf(string_buffer2, "ENPR %d", level);

        generate_code(string_buffer, string_buffer2);
        insert_symbol_table_proc(&table, level, token, label_count);
    }
    procedure_params SEMICOLON block
    {
        // PROCEDURE RETURN
        sprintf(string_buffer, "RTPR %d,%d", level, param_count);
        generate_code(NULL, string_buffer);

        print_symbol_table(&table);
        // REMOVE SYMBOLS
        remove_symbols_from_table_until_proc(&table, level);
        print_symbol_table(&table);


        // OUT OF PROCEDURE
        stack_pop(&label_stack, &return_label);
        sprintf(string_buffer, "R%.2d", return_label);
        generate_code(string_buffer, "NADA");
        level--;
    }

    // FUNCTION (WITH RETURN VALUE) */

;

procedure_params:
    OPEN_PARENTHESIS
    { param_count = 0;}
    declare_params
    {
        update_symbol_table_offset(&table, param_count, level);
        symbol_table_last_proc_index(&table, &proc_index);
        table.stack[proc_index].param_num = param_count;
    
    }
    CLOSE_PARENTHESIS | %empty 
;

declare_params: declare_params declare_param | declare_param;


declare_param:
    by_reference_or_not
    {list_size = 0;}
    id_param_list COLON type
    { 
        /* SET VARIABLE TYPES */
        list_type = get_type(token);
        if (not list_type)
        {
            sprintf(string_buffer, "Unsupported type '%s'", token);
            print_error(string_buffer);
        }

        update_symbol_table_type(&table, list_size, list_type);

        symbol_table_last_proc_index(&table, &proc_index);
        symbol_table_update_proc_param_array(&table, proc_index, list_size, list_type, by_reference);

        print_symbol_table(&table);
    }
    optional_semicolon
;

by_reference_or_not:
    VAR {by_reference = true;} |  %empty {by_reference = false;}
;

id_param_list:
    id_param_list COMMA IDENT
    { /* last symbol insert */
        insert_symbol_table_param(&table, level, token, by_reference);
        list_size++;
        param_count++;
    }
    | IDENT
    { /* first to penultimate symbol insert */
        insert_symbol_table_param(&table, level, token, by_reference);
        list_size++;
        param_count++;
    }
;


optional_semicolon: SEMICOLON | %empty  ;

/* COMMANDS */

compound_command: T_BEGIN commands T_END;

commands: commands command | command;

/* command: assignment_operation | compound_command | loop | conditional | read | write; */
command: assignment_operation  | loop | conditional | read | write | procedure_call;


procedure_call:
    IDENT
    {
        strcpy(token, $<text>1);

        assert_symbol_exists(&table, token);
        search_symbol_table_index(&table, token, &proc_index);
        assert_equal_things(table.stack[proc_index].category, PROCEDURE_CATEGORY, "Category");
        symbol_table_get_proc_arrays(&table, proc_index, &proc_types, &proc_byrefs, &proc_num_params);
        parsed_params = 0;


        stack_push(&proc_stack, proc_index);
    } 
    OPEN_PARENTHESIS procedure_arguments CLOSE_PARENTHESIS
    {
        stack_pop(&proc_stack, &proc_index);
        int label = table.stack[proc_index].label;

        sprintf(string_buffer, "CHPR R%.2d, %d", label, level);

        generate_code(NULL, string_buffer);

    }
    SEMICOLON
;

procedure_arguments:
    args_list 
;

args_list: args_list COMMA ARGUMENT | ARGUMENT;

ARGUMENT: 
    IDENT
    {
        strcpy(token, $<text>1);

        // load var
        assert_symbol_exists(&table, token);
        printf("\nLOAD VARIABLE %s\n", token);

        // get type
        search_symbol_table_index(&table, token, &symbol_index);
        int type = table.stack[symbol_index].type;
        // int by_reference = table.stack[symbol_index].by_reference;

        assert_equal_things(type, proc_types[parsed_params], "Type");
        // assert_equal_things(by_reference, proc_byrefs[parsed_params], "By Reference");
        bool by_reference = proc_byrefs[parsed_params];

        int level, offset;
        search_symbol_table(&table, token, &level, &offset);
        
        if (not by_reference)
            // load value
            sprintf(string_buffer, "CRVL %d,%d", level, offset);
        else
            // load address
            sprintf(string_buffer, "CREN %d,%d", level, offset);
        
        generate_code(NULL, string_buffer);
        parsed_params++;
    }
    | boolean_expr 
    {
        // get expr type
        int type;
        stack_pop(&e_stack, &type);

        assert_equal_things(type, proc_types[parsed_params], "Type");
        assert_equal_things(false, proc_byrefs[parsed_params], "By Reference");

        parsed_params++;
    }
;



/* READ and WRITE*/
read:
    READ OPEN_PARENTHESIS IDENT
    {
        printf("\nIDENT ARGUMENT OF READ()\n");
        assert_symbol_exists(&table, token);
        search_symbol_table(&table, token, &read_level, &read_offset);

        int symbol_index;
        search_symbol_table_index(&table, token, &symbol_index);
        int category = table.stack[left_side_index].category;
        bool byref = table.stack[left_side_index].by_reference;

        if (category == PROCEDURE_CATEGORY)
            print_error("Trying to READ procedure?");

        generate_code(NULL, "LEIT");

        if (byref)
            sprintf(string_buffer, "ARMI %d,%d", read_level, read_offset);
        else
            sprintf(string_buffer, "ARMZ %d,%d", read_level, read_offset);

        generate_code(NULL, string_buffer);
    }
    CLOSE_PARENTHESIS SEMICOLON
;

write: WRITE OPEN_PARENTHESIS write_boolean_expr_list CLOSE_PARENTHESIS SEMICOLON;

write_boolean_expr_list:
    write_boolean_expr_list COMMA boolean_expr
    { generate_code(NULL, "IMPR");}
    | boolean_expr
    { generate_code(NULL, "IMPR");}
;


/* WHILE */

loop:
    WHILE
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
    }
;

/* IF CONDITIONAL */
conditional:
    if_then cond_else 
    { 
        stack_pop(&label_stack, &return_label);
        sprintf(string_buffer, "R%.2d", return_label);
        generate_code(string_buffer, "NADA");
    }
;

if_then:
    IF boolean_expr
    {
        label_count += 1;
        stack_push(&label_stack, label_count);
        sprintf(string_buffer, "DSVF R%.2d", label_count);
        generate_code(NULL, string_buffer);
    }
    THEN command
;

cond_else :
    ELSE 
    {
        stack_pop(&label_stack, &return_label);
        label_count += 1;

        sprintf(string_buffer, "DSVS R%.2d", label_count);
        generate_code(NULL, string_buffer);

        sprintf(string_buffer, "R%.2d", return_label);
        generate_code(string_buffer, "NADA");

        stack_push(&label_stack, label_count);
    }
    command |  %empty %prec LOWER_THAN_ELSE
;


/* ASSIGNMENT OPERATION */

assignment_operation:
    IDENT
    {
        // printf("\n\ntoken: '%s'\n $1: '%s'", token, $<text>1);

        strcpy(token, $<text>1);

        printf("\nIDENT LEFT SIDE OF ASSIGNMENT\n");
        assert_symbol_exists(&table, token);
        search_symbol_table(&table, token, &left_side_level, &left_side_offset);
        search_symbol_table_index(&table, token, &left_side_index);
    }
    ASSIGNMENT boolean_expr SEMICOLON
    {
        int expr_type;
        stack_pop(&e_stack, &expr_type);
        left_side_type = table.stack[left_side_index].type;
        bool byref = table.stack[left_side_index].by_reference;

        if (left_side_type != expr_type)
            print_error("LS Type Error");

        if (byref)
            sprintf(string_buffer, "ARMI %d,%d", left_side_level, left_side_offset);
        else
            sprintf(string_buffer, "ARMZ %d,%d", left_side_level, left_side_offset);
        generate_code(NULL, string_buffer);
    }
;

/* BOOLEAN EXPRESSIONS */

boolean_expr:

    arithmetic_expr |
    boolean_expr EQUAL arithmetic_expr
    {
        int type = assert_equal_types(&e_stack, &e_stack);
        generate_code(NULL, "CMIG"); 
        stack_push(&e_stack, BOOL_TYPE);
    } |
    boolean_expr DIFFERENT arithmetic_expr
    {
        int type = assert_equal_types(&e_stack, &e_stack);
        generate_code(NULL, "CMDG"); 
        stack_push(&e_stack, BOOL_TYPE);
    } |
    boolean_expr LESS_OR_EQUAL arithmetic_expr
    {
        int type = assert_equal_types(&e_stack, &e_stack);
        generate_code(NULL, "CMEG"); 
        stack_push(&e_stack, BOOL_TYPE);
    } |
    boolean_expr LESS arithmetic_expr
    {
        int type = assert_equal_types(&e_stack, &e_stack);
        generate_code(NULL, "CMME"); 
        stack_push(&e_stack, BOOL_TYPE);
    } |
    boolean_expr MORE_OR_EQUAL arithmetic_expr
    {
        int type = assert_equal_types(&e_stack, &e_stack);
        generate_code(NULL, "CMAG"); 
        stack_push(&e_stack, BOOL_TYPE);
    } |
    boolean_expr MORE arithmetic_expr
    {
        int type = assert_equal_types(&e_stack, &e_stack);
        generate_code(NULL, "CMMA"); 
        stack_push(&e_stack, BOOL_TYPE);
    }
;

/* ARITHMETIC EXPRESSIONS */

arithmetic_expr: E;

E: 
    E PLUS T 
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
    }
;

T:
    T ASTERISK F 
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
    }
;

F:
    NUMBER
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
        printf("\nIDENT ARGUMENT OF boolean_expr\n");
        assert_symbol_exists(&table, token);
        printf("\nLOAD VARIABLE %s\n", token);

        // stack type
        search_symbol_table_index(&table, token, &symbol_index);
        int type = table.stack[symbol_index].type;
        bool byref = table.stack[symbol_index].by_reference;
        stack_push(&f_stack, type);

        // load value
        int level, offset;
        search_symbol_table(&table, token, &level, &offset);

        if (byref)
            sprintf(string_buffer, "CREN %d,%d", level, offset);
        else
            sprintf(string_buffer, "CRVL %d,%d", level, offset);

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

    /* yydebug = 1; */

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
    init_stack(&proc_stack);


    yyin=fp;
    yyparse();

    return 0;
}
