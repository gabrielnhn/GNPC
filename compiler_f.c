// Autor: Bruno Müller Junior
// Data: 08/2007
// Editado por Gabriel Nascarella Hishida do Nascimento
// Funções auxiliares ao compiler

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "compiler.h"

/* -------------------------------------------------------------------
 *  variáveis globais
 * ------------------------------------------------------------------- */

symbols symbol, relation;
char token[TOKEN_SIZE];

char a_string_buffer[MAX_SYMBOL_NAME];


FILE *fp = NULL;
void generate_code(char *rot, char *comando)
{

	if (fp == NULL)
	{
		fp = fopen("MEPA", "w");
	}

	if (rot == NULL)
	{
		fprintf(fp, "     %s\n", comando);
		fflush(fp);
	}
	else
	{
		fprintf(fp, "%s: %s \n", rot, comando);
		fflush(fp);
	}
}

int print_error(char *erro)
{
	fprintf(stderr, "Error on line %d: %s\n", nl, erro);
	exit(-1);
}

/// symbol table

void init_symbol_table(symbol_table *table)
{
	table->size = -1;
}

void insert_symbol_table_simple_var(symbol_table *table, int level, int offset, char *name)
{
	int possible_level, possible_offset;
	if (search_symbol_table(table, name, &possible_level, &possible_offset) == true)
	{
		if (possible_level == level)
		{
            print_symbol_table(table);
			print_error("Same variable name on same lexical level\n");
		}
	}

	table->size += 1;

	table->stack[table->size].level = level;
	table->stack[table->size].offset = offset;
	table->stack[table->size].type = -1;
    table->stack[table->size].category = SIMPLE_VAR_CATEGORY;

	table->stack[table->size].name = (char *)malloc(strnlen(name, MAX_SYMBOL_NAME) + 1);

	if (table->stack[table->size].name == NULL)
	{
		print_error("malloc() FAILED\n");
	}

	strncpy(table->stack[table->size].name, name, strnlen(name, MAX_SYMBOL_NAME));
}

void update_symbol_table_type(symbol_table *table, int symbols_to_update, int type)
{
	int i = table->size;
	while (i > table->size - symbols_to_update)
	{
		if (i < 0)
		{
			print_error("Trying to set type of non-existing symbol\n");
		}

		table->stack[i].type = type;
		i--;
	}
}

void remove_symbols_from_table(symbol_table *table, int symbols_to_remove)
{
	int i = table->size;
	while (i > table->size - symbols_to_remove)
	{
		if (i < 0)
		{
			print_error("Trying to remove non-existing symbol\n");
		}

		free(table->stack[i].name);
		i--;
	}

	table->size -= symbols_to_remove;
}

void print_symbol_table(symbol_table *table)
{
	for (int i = 0; i <= table->size; i++)
	{
		symbol_t s = table->stack[i];
		printf("Symbol %s - l%d off%d t%d ", s.name, s.level, s.offset, s.type);
        if (s.category == PARAM_CATEGORY)
            printf("Byref:%d", s.by_reference);

        if ((s.category == PROCEDURE_CATEGORY) or (s.category == FUNCTION_CATEGORY))
        {
            printf("{");
            for(int i = 0; i < s.param_num; i++)
                printf("[t%d, byr%d], ", s.param_types[i], s.param_byrefs[i]);
            printf("}");
        }

        printf("\n"); 
	}
}

// true if found, false otherwise. Return level and offset by reference.
bool search_symbol_table(symbol_table *table, char *name, int *level, int *offset)
{
	for (int i = table->size; i >= 0; i--)
	{
		bool comparison = strncmp(table->stack[i].name, name, MAX_SYMBOL_NAME);
		if (comparison == 0)
		{
			*level = table->stack[i].level;
			*offset = table->stack[i].offset;

			return true;
		}
	}

	// not found
	return false;
}

int get_type(char *type)
{
	if (strncmp(type, "integer", MAX_SYMBOL_NAME) == 0)
		return INTEGER_TYPE;

	else
		return 0;
}

bool search_symbol_table_index(symbol_table *table, char *name, int *index)
{
	for (int i = table->size; i >= 0; i--)
	{
		bool comparison = strncmp(table->stack[i].name, name, MAX_SYMBOL_NAME);

		if (comparison == 0)
		{
			*index = i;
			return true;
		}
	}
	// not found
	return false;
}


void assert_symbol_exists(symbol_table *table, char *name)
{
	int symbol_index;
	if (search_symbol_table_index(table, token, &symbol_index) == false)
	{
		sprintf(a_string_buffer, "Name '%s' does not exist", token);
		print_error(a_string_buffer);
	}
}


void init_stack(stack_t *stack)
{
	stack->top = -1;
}

bool stack_push(stack_t *stack, int x)
{
	if (stack->top + 1 < MAX_SYMBOLS)
	{
		stack->top++;
		stack->array[stack->top] = x;
		return true;
	} 
	else
		print_error("Stack overflow");
}


bool stack_pop(stack_t *stack, int* x)
{
	if (stack->top >= 0)
	{
		*x = stack->array[stack->top];
		stack->top--;
		return true;
	} 
	else
		print_error("Stack is empty!");
;
}



int assert_equal_types(stack_t* a, stack_t* b)
{
	int a_type, b_type;
	stack_pop(a, &a_type);
	stack_pop(b, &b_type);

	if (a_type != b_type)
	{
		print_error("Type Error");
	}

	return a_type;
}

void insert_symbol_table_param(symbol_table *table, int level, char *name, bool byref)
{
	int possible_level, possible_offset;
	if (search_symbol_table(table, name, &possible_level, &possible_offset) == true)
		if (possible_level == level)
			print_error("Same variable name on same lexical level\n");

	table->size += 1;
	table->stack[table->size].level = level;
	table->stack[table->size].type = -1;
    table->stack[table->size].category = PARAM_CATEGORY;
    table->stack[table->size].by_reference = byref;

	table->stack[table->size].name = (char *)malloc(strnlen(name, MAX_SYMBOL_NAME) + 1);
	if (table->stack[table->size].name == NULL)
		print_error("malloc() FAILED\n");

	strncpy(table->stack[table->size].name, name, strnlen(name, MAX_SYMBOL_NAME));
}

void update_symbol_table_offset(symbol_table *table, int symbols_to_update, int level)
{
    int offset = level - 4;
	int i = table->size;
	while (i > table->size - symbols_to_update)
	{
		if (i < 0)
		{
			print_error("Trying to set type of non-existing symbol\n");
		}

		table->stack[i].offset = offset;
        offset--;
		i--;
	}
}

void insert_symbol_table_proc(symbol_table *table, int level, char *name, int label)
{
	int possible_level, possible_offset;
	if (search_symbol_table(table, name, &possible_level, &possible_offset) == true)
		if (possible_level == level)
			print_error("Same variable name on same lexical level\n");

	table->size += 1;
	table->stack[table->size].level = level;
	table->stack[table->size].type = -1;
    table->stack[table->size].category = PROCEDURE_CATEGORY;
    table->stack[table->size].label = label;
    table->stack[table->size].param_types[0] = -1;
    table->stack[table->size].param_byrefs[0] = -1;
    table->stack[table->size].param_num = 0;


	table->stack[table->size].name = (char *)malloc(strnlen(name, MAX_SYMBOL_NAME) + 1);
	if (table->stack[table->size].name == NULL)
		print_error("malloc() FAILED\n");

	strncpy(table->stack[table->size].name, name, strnlen(name, MAX_SYMBOL_NAME));
}

void remove_symbols_from_table_until_proc(symbol_table *table)
{
	int i = table->size;
	while (true)
	{
		if (i < 0)
		{
			print_error("Trying to remove non-existing symbol\n");
		}

        if ((table->stack[i].category == PROCEDURE_CATEGORY) or (table->stack[i].category == FUNCTION_CATEGORY))
            break;

		free(table->stack[i].name);
		i--;
	    table->size -= 1;
	}

}

bool symbol_table_last_proc_index(symbol_table *table, int *index)
{
	for (int i = table->size; i >= 0; i--)
	{
        if ((table->stack[i].category == PROCEDURE_CATEGORY) or (table->stack[i].category == FUNCTION_CATEGORY))
        {
			*index = i;
			return true;
		}
	}
	// not found
	return false;
}

void symbol_table_update_proc_param_array(symbol_table *table, int index, int params_to_update, int type, bool byref)
{
    symbol_t* proc = &(table->stack[index]);

    int where_to_start = 0;
    while(proc->param_types[where_to_start] != -1)
    {
        where_to_start++;
        if ((where_to_start + params_to_update - 1) > MAX_PARAMS_SIZE)
        {
            print_error("All params were filled?");
        }
    }

    int i;
    for(i = where_to_start; i < where_to_start + params_to_update; i++)
    {
        proc->param_byrefs[i] = byref;
        proc->param_types[i] = type;
    }

    proc->param_byrefs[i] = -1;
    proc->param_types[i] = -1;

}

void symbol_table_get_proc_arrays(symbol_table *table, int index, int** types, int** byrefs, int* num)
{
    symbol_t* proc = &(table->stack[index]);

    if ((proc->category != FUNCTION_CATEGORY) and (proc->category != PROCEDURE_CATEGORY))
        print_error("Symbol is not a procedure/function");

    *byrefs = proc->param_byrefs;
    *types = proc->param_types;
    *num = proc->param_num;
}

int assert_equal_things(int a, int b, char* thing)
{

	if (a != b)
	{
        sprintf(a_string_buffer, "%s Error", thing);
		print_error(a_string_buffer);
	}

	return a;
}


void insert_symbol_table_function(symbol_table *table, int level, char *name, int label)
{
	int possible_level, possible_offset;
	if (search_symbol_table(table, name, &possible_level, &possible_offset) == true)
		if (possible_level == level)
			print_error("Same variable name on same lexical level\n");

	table->size += 1;
	table->stack[table->size].level = level;
	table->stack[table->size].type = -1;
    table->stack[table->size].category = PROCEDURE_CATEGORY;
    table->stack[table->size].label = label;
    table->stack[table->size].param_types[0] = -1;
    table->stack[table->size].param_byrefs[0] = -1;
    table->stack[table->size].param_num = 0;


	table->stack[table->size].name = (char *)malloc(strnlen(name, MAX_SYMBOL_NAME) + 1);
	if (table->stack[table->size].name == NULL)
		print_error("malloc() FAILED\n");

	strncpy(table->stack[table->size].name, name, strnlen(name, MAX_SYMBOL_NAME));
}
