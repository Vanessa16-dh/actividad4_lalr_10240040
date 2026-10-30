%option noyywrap yylineno nounput noinput

%{
/* Matricula: 10240040 | Nombre: VANESSA RODRIGUEZ MARTINEZ */
#include "parser_lalr.tab.h"
#include <stdio.h>

#define MAX_LEXEMA 31

void registrar_identificador(const char *lexema, int linea);
%}

LETRA       [a-zA-Z_]
DIGITO      [0-9]
ID_VALIDO   {LETRA}({LETRA}|{DIGITO})*
NUMERO_VAL  {DIGITO}+([.]{DIGITO}+)?

%%

[ \t\r]+    { /* Ignorar espacios y tabuladores */ }
\n          { /* Ignorar saltos de línea, yylineno se actualiza solo */ }
"//"[^\n]*  { /* Ignorar comentarios de una línea */ }

{ID_VALIDO} {
    if (yyleng > MAX_LEXEMA) {
        fprintf(stderr, "ERROR_LEXICO linea=%d identificador_demasiado_largo\n", yylineno);
        return (unsigned char) yytext[0];
    }
    registrar_identificador(yytext, yylineno);
    return ID;
}

{NUMERO_VAL} {
    return NUMERO;
}

"="     { return ASIGNA; }
"+"     { return SUMA; }
"-"     { return RESTA; }
"*"     { return MULTIPLICA; }
"/"     { return DIVIDE; }
"^"     { return POTENCIA; }
"("     { return PAR_IZQ; }
")"     { return PAR_DER; }
";"     { return PUNTO_COMA; }

.       { return (unsigned char) yytext[0]; }

%%
