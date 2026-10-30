CC = gcc
CFLAGS = -D_POSIX_C_SOURCE=200809L -std=c11 -Wall -Wextra -Wpedantic -Werror

parser_lalr: parser_lalr.tab.c lex.yy.c
	$(CC) $(CFLAGS) parser_lalr.tab.c lex.yy.c -o parser_lalr

parser_lalr.tab.c parser_lalr.tab.h parser_lalr.output: parser_lalr.y
	bison -Wall -d -v --report=state,solved parser_lalr.y

lex.yy.c: lexer.l parser_lalr.tab.h
	flex -o lex.yy.c lexer.l

test: parser_lalr
	./parser_lalr pruebas/valido.ci
	./parser_lalr pruebas/regresion_unario.ci
	./parser_lalr pruebas/potencia.ci
	@./parser_lalr pruebas/limite.ci; codigo=$$?; test $$codigo -eq 1
	@./parser_lalr pruebas/errores.ci; codigo=$$?; test $$codigo -eq 1
	@./parser_lalr pruebas/confusion.ci; codigo=$$?; test $$codigo -eq 1
	@./parser_lalr >/dev/null 2>&1; codigo=$$?; test $$codigo -eq 2
	@./parser_lalr pruebas/no_existe.ci >/dev/null 2>&1; codigo=$$?; test $$codigo -eq 2

clean:
	rm -f parser_lalr parser_lalr_san parser_lalr.tab.c parser_lalr.tab.h parser_lalr.output lex.yy.c *.o *.stdout *.stderr

.PHONY: test clean
