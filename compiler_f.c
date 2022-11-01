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
  fprintf (stderr, "Erro na linha %d - %s\n", nl, erro);
  exit(-1);
}




/// symbol table

void init_symbol_table(symbol_table* table)
{
    table->size = -1;
}


void insert_symbol_table(symbol_table* table, int level, int offset, char* name)
{
    table->size += 1;

    table->stack[table->size].level = level;
    table->stack[table->size].offset = offset;
    table->stack[table->size].type = -1;
    
    table->stack[table->size].name = (char*) malloc(strnlen(name, MAX_SYMBOL_NAME) + 1);


    if (table->stack[table->size].name == NULL)
    {
      perror("BRUH MALLOC FAILED\n");
      exit(0);
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
            perror("SOMETHING REALLY WRONG HAPPENED MATE\n");
            perror("Trying to set type of non-existing symbol\n");
            exit(0);
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
            perror("SOMETHING REALLY WRONG HAPPENED MATE\n");
            perror("Trying to remove non-existing symbol\n");
        }
        
        // REMOVE OPTIONAL CONTENT?
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

