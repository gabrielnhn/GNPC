/* -------------------------------------------------------------------
 *            Arquivo: compiler.h
 * -------------------------------------------------------------------
 *              Autor: Bruno Muller Junior
 *               Data: 08/2007
 *      Atualizado em: [09/08/2020, 19h:01m]
 *
 * -------------------------------------------------------------------
 *
 * Tipos, protótipos e variáveis globais do compiler (via extern)
 *
 * ------------------------------------------------------------------- */

#define TOKEN_SIZE 16

typedef enum symbols
{
    symb_program, symb_var, symb_begin, symb_end,
    symb_identifier, symb_number, symb_dot, symb_comma,
    symb_semicolon, symb_colon, symb_assignment,
    symb_open_parenthesis, symb_close_parenthesis, symb_label,
    symb_type, symb_array, symb_of, symb_procedure,
    symb_goto, symb_if, symb_then, symb_else,
    symb_while, symb_do, symb_or, symb_and, symb_not,
    symb_div, symb_asterisk, symb_plus, symb_minus,
} symbols;

/* -------------------------------------------------------------------
 * variáveis globais
 * ------------------------------------------------------------------- */

extern symbols symbol, relation;
extern char token[TOKEN_SIZE];
extern int lexical_level;
extern int desloc;
extern int nl;

/* -------------------------------------------------------------------
 * prototipos globais
 * ------------------------------------------------------------------- */

void generate_code(char *, char *);
int yylex();
void yyerror(const char *s);
