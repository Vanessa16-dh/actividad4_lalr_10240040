# Actividad 4: Construcción guiada de un analizador ascendente LALR con GNU Bison

## Datos del Estudiante y Objetivo
* **Nombre Completo:** VANESSA RODRIGUEZ MARTINEZ
* **Matrícula:** 10240040
* **Grupo:** ISC-01
* **Objetivo:** Construir, probar y documentar un analizador sintáctico ascendente LALR en C11 utilizando GNU Bison y Flex para un lenguaje de asignaciones y expresiones aritméticas, integrando manejo de precedencia, asociatividad a la derecha para la potencia, menos unario, recuperación de errores mediante token de sincronización `;` y catálogo de identificadores.

## Requisitos del Entorno
* WSL (Ubuntu)
* GNU Bison 3.6 o posterior
* Flex
* GCC con soporte C11
* GNU Make, Git, zip y unzip

## Comandos de Compilación y Prueba
* **Compilación general:** `make clean && make`
* **Suite automatizada de pruebas:** `make test`
* **Compilación con sanitizadores:**
  ```bash
  gcc -D_POSIX_C_SOURCE=200809L -std=c11 -Wall -Wextra -Wpedantic -Werror -fsanitize=address,undefined -fno-omit-frame-pointer parser_lalr.tab.c lex.yy.c -o parser_lalr_san
  ./parser_lalr_san pruebas/valido.ci
  ./parser_lalr_san pruebas/errores.ci```
## Códigos de Salida del Ejecutable
- **0**: Entrada aceptada sintácticamente sin errores ni desbordamientos de catálogo[cite: 26].
- **1**: Ocurrió al menos un error léxico, error sintáctico o desbordamiento de capacidad de la tabla de identificadores (`ERROR_TABLA`)[cite: 26].
- **2**: Uso incorrecto del programa (argumentos inválidos) o fallo al intentar abrir el archivo fuente especificado[cite: 26].

## Decisiones de Diseño y Mecanismos Sintácticos
- **Precedencia y asociatividad:** La suma y resta poseen la menor precedencia (`%left`), seguidas de la multiplicación y división (`%left`)[cite: 9, 10]. El menos unario (`%precedence NEGATIVO`) supera a las operaciones binarias estándar, mientras que el operador de potencia (`%right POTENCIA`) ostenta la mayor precedencia y asociatividad a la derecha[cite: 4, 10, 28, 29].
- **Recuperación de errores:** Implementada mediante la regla `error PUNTO_COMA`[cite: 13, 14]. El punto y coma `;` actúa como token de sincronización, permitiendo descartar la sentencia dañada, limpiar el estado de error con `yyerrok` y continuar el análisis con las sentencias posteriores[cite: 4, 13, 14].
- **Catálogo de identificadores:** Almacena el lexema, primera línea de aparición y número de apariciones. Es un catálogo léxico y no una tabla de símbolos semántica[cite: 4, 7, 8].

## Respuestas a Preguntas de Razonamiento (Sección 17)
1. **¿Qué elemento puede desplazarse y qué producción puede reducirse?**
   - **Respuesta:** En el reporte de estados de `parser_lalr.output`, ante un ítem con el punto previo a un terminal como `sentencia: ID ASIGNA expresion . PUNTO_COMA`, el token `;` puede desplazarse (`shift`). En un ítem donde el punto se ubica al final de la regla, como `expresion: expresion SUMA expresion .`, el parser reconoce la regla completa y realiza una reducción (`reduce`)[cite: 27].

2. **¿Por qué la recursión izquierda de expresion es apropiada para un parser LALR y cómo intervienen las declaraciones de precedencia?**
   - **Respuesta:** La recursión por la izquierda es natural en parsers LR/LALR porque evalúan la entrada mediante reducciones sobre una pila sin generar recursión infinita[cite: 3]. Las ambigüedades derivadas de reglas generales como `expresion SUMA expresion` son resueltas explícitamente mediante las directivas `%left`, `%right` y `%precedence`[cite: 10, 12, 28].

3. **¿Qué es el punto de sincronización, qué hace error PUNTO_COMA y qué salida de errores.ci demuestra que el análisis continuó?**
   - **Respuesta:** El punto de sincronización es un token límite seguro (el `;`) para reanudar el análisis[cite: 4]. La regla `error PUNTO_COMA` descarta tokens erróneos hasta encontrar `;` y ejecuta `yyerrok`[cite: 13, 14]. La salida de `errores.ci` lo demuestra al registrar `RESUMEN sentencias_validas=2 errores_sintacticos=2 recuperaciones=2`, confirmando que las sentencias `b = 5;` y `d = b + 1;` fueron analizadas correctamente tras los errores[cite: 25, 26].

4. **¿Por qué el catálogo de identificadores no es una tabla de símbolos semántica?**
   - **Respuesta:** Porque solo registra apariciones léxicas sin validar aspectos semánticos[cite: 4, 8]. No comprueba la declaración previa del identificador, ni el tipo de dato, ámbito o compatibilidad en expresiones[cite: 1].

5. **En confusion.ci, ¿por qué = es válido como ASIGNA pero == provoca un error?**
   - **Respuesta:** Porque Flex reconoce el primer `=` de `==` como un token `ASIGNA` independiente[cite: 25, 26]. Tras analizar la expresión previa, el parser no espera un token `ASIGNA` consecutivo en la gramática, produciendo un `ERROR_SINTACTICO` por token inesperado[cite: 25, 26].

6. **¿Qué línea de parser_lalr.output demuestra la asociatividad derecha de POTENCIA y qué regresión protege el menos unario?**
   - **Respuesta:** La línea `Conflict between rule ... and token POTENCIA resolved as shift (%right POTENCIA)` demuestra que ante un segundo `^` se prefiere desplazar[cite: 29]. El menos unario (`%prec NEGATIVO`) protege la interpretación de expresiones como `saldo = -cantidad * 2;` en `regresion_unario.ci`, garantizando que `-` se agrupe como operador unario sobre `cantidad` y no como resta binaria[cite: 12, 25].
## URL Repositorio 
* ** https://github.com/Vanessa16-dh/actividad4_lalr_10240040.git **
