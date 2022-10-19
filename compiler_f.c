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
