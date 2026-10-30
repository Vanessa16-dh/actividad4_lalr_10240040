%{
/* Matricula: 10240040 | Nombre:VANESSA RODRIGUEZ MARTINEZ */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_IDENTIFICADORES 32
#define MAX_LEXEMA 31

typedef struct {
    char lexema[MAX_LEXEMA + 1];
    int primera_linea;
    int apariciones;
} EntradaIdentificador;

static EntradaIdentificador tabla[MAX_IDENTIFICADORES];
static int cantidad_identificadores = 0;
static int sentencias_validas = 0;
static int errores_sintacticos = 0;
static int recuperaciones = 0;
static int error_tabla = 0;

int yylex(void);
int yylex_destroy(void);
void yyerror(const char *mensaje);
void registrar_identificador(const char *lexema, int linea);

extern int yylineno;
extern char *yytext;
extern FILE *yyin;
%}

%define lr.type lalr
%define parse.error detailed
%define parse.lac full

%token ID NUMERO
%token ASIGNA SUMA RESTA MULTIPLICA DIVIDE POTENCIA
%token PAR_IZQ PAR_DER PUNTO_COMA

%left SUMA RESTA
%left MULTIPLICA DIVIDE
%right POTENCIA
%precedence NEGATIVO

%start programa

%%

programa
    : %empty
    | programa sentencia
    ;

sentencia
    : ID ASIGNA expresion PUNTO_COMA
      { sentencias_validas++; }
    | error PUNTO_COMA
      { recuperaciones++; yyerrok; }
    ;

expresion
    : NUMERO
    | ID
    | PAR_IZQ expresion PAR_DER
    | expresion SUMA expresion
    | expresion RESTA expresion
    | expresion MULTIPLICA expresion
    | expresion DIVIDE expresion
    | expresion POTENCIA expresion
    | RESTA expresion %prec NEGATIVO
    ;

%%

void registrar_identificador(const char *lexema, int linea)
{
    for (int i = 0; i < cantidad_identificadores; i++) {
        if (strcmp(tabla[i].lexema, lexema) == 0) {
            tabla[i].apariciones++;
            return;
        }
    }
    if (cantidad_identificadores >= MAX_IDENTIFICADORES) {
        fprintf(stderr, "ERROR_TABLA capacidad=%d\n", MAX_IDENTIFICADORES);
        error_tabla = 1;
        return;
    }
    EntradaIdentificador *entrada = &tabla[cantidad_identificadores];
    snprintf(entrada->lexema, sizeof entrada->lexema, "%s", lexema);
    entrada->primera_linea = linea;
    entrada->apariciones = 1;
    cantidad_identificadores++;
}

void yyerror(const char *mensaje)
{
    errores_sintacticos++;
    fprintf(stderr, "ERROR_SINTACTICO linea=%d cerca de \"%s\" detalle=%s\n", yylineno, yytext, mensaje);
}

static void imprimir_tabla(void)
{
    puts("TABLA_IDENTIFICADORES");
    for (int i = 0; i < cantidad_identificadores; i++) {
        printf("%s primera_linea=%d apariciones=%d\n",
               tabla[i].lexema,
               tabla[i].primera_linea,
               tabla[i].apariciones);
    }
}

int main(int argc, char **argv)
{
    if (argc != 2) {
        fprintf(stderr, "USO: %s archivo.ci\n", argv[0]);
        return 2;
    }
    yyin = fopen(argv[1], "r");
    if (yyin == NULL) {
        perror("No se pudo abrir el archivo");
        return 2;
    }
    int resultado_bison = yyparse();
    fclose(yyin);
    yylex_destroy();

    imprimir_tabla();
    printf("RESUMEN sentencias_validas=%d errores_sintacticos=%d recuperaciones=%d identificadores=%d\n",
           sentencias_validas, errores_sintacticos,
           recuperaciones, cantidad_identificadores);

    return (resultado_bison == 0 && errores_sintacticos == 0 && error_tabla == 0) ? 0 : 1;
}
