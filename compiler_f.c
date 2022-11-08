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

FILE* fp=NULL;
void generate_code (char* rot, char* comando) {

  if (fp == NULL) {
    fp = fopen ("MEPA", "w");
  }

  if ( rot == NULL ) {
    fprintf(fp, "     %s\n", comando); fflush(fp);
  } else {
    fprintf(fp, "%s: %s \n", rot, comando); fflush(fp);
  }
}

int print_error ( char* erro ) {
  fprintf (stderr, "Error on line %d - %s\n", nl, erro);
  exit(-1);
}




/// symbol table

void init_symbol_table(symbol_table* table)
{
    table->size = -1;
}


void insert_symbol_table(symbol_table* table, int level, int offset, char* name)
{
	int possible_level, possible_offset;
	if (search_symbol_table(table, name, &possible_level, &possible_offset) == true)
	{
		if (possible_level == level)
		{
			print_error("SAME VARIABLE NAME ON SAME LEXICAL LEVEL\n");
		}
	}



    table->size += 1;

    table->stack[table->size].level = level;
    table->stack[table->size].offset = offset;
    table->stack[table->size].type = -1;
    
    table->stack[table->size].name = (char*) malloc(strnlen(name, MAX_SYMBOL_NAME) + 1);


    if (table->stack[table->size].name == NULL)
    {
      print_error("BRUH MALLOC FAILED\n");
    }

    // printf("\nPOINTER EXISTS IN %p\n", table->stack[table->size].name);


    strncpy(table->stack[table->size].name, name, strnlen(name, MAX_SYMBOL_NAME));


}

void update_symbol_table_type(symbol_table* table, int symbols_to_update, int type)
{
    int i = table->size;
    while (i > table->size - symbols_to_update)
    {
        if (i < 0)
        {
            print_error("Trying to set type of non-existing symbol\n");
        }
        
        table->stack[i].type = type;
      i++;
    }
}


void remove_symbols_from_table(symbol_table* table, int symbols_to_remove)
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

void print_symbol_table(symbol_table* table)
{
    for(int i=0; i <= table->size; i++)
    {
        symbol_t s = table->stack[i];
        printf("Symbol %s - l%d off%d t%d\n", s.name, s.level, s.offset, s.type);
    }
}


// true if found, false otherwise. Return level and offset by reference.
bool search_symbol_table(symbol_table* table, char* name, int* level, int* offset)
{
	for(int i = table->size; i >= 0; i--)
	{
		bool comparison = strncmp(table->stack[i].name, name, MAX_SYMBOL_NAME);

		if (comparison == 0)
		{
			// printf("\n%s is %s, search is true\n", table->stack[i].name, name);

			// found
			*level = table->stack[i].level;
			*offset = table->stack[i].offset;
			
			return true;
		}  
		else
		{
			// printf("\n%s is not %s, search is ongoing\n", table->stack[i].name, name);

		}
	}

	// not found
	return false;

}