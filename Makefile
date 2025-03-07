### Makefile generique pour Flex seul ou Flex/Bison combin�
# - Nommage : XX.flex et XX.bison => Analyseurs XX ou lex-XX ou parse-XX
# - Pas de librairies -ll -y : Ecrire dans les specs 
#      les fonctions yywrap(), yyerror() et main()
# - Couplage Flex/Bison : #include "yyparse.h"
# - Un define FLEXALONE permet d'ecrire une spec Flex commune
#      pour le mode Flex seul et le mode Flex/Bison combin�
# - Integration de code externe hors spec : ajouter des regles
#      mon_analyseur : EXT_SRC = mon_code.c 
# - Ajouter "%option nounput noinput" dans les spec flex pour
#      eviter des warnings avec gcc -Wall

USAGE ="USAGE :  \
\n make XX  \
\n    XX.flex => XX : Analyseur Lexical, si XX.bison absent  \
\n    XX.flex + XX.bison => XX : Analyseur Syntaxique  \
\n make lex-XX  \
\n   XX.flex => lex-XX : Analyseur Lexical, meme si XX.bison existe  \
\n make parse-XX  \
\n    XX.flex + XX.bison => parse-XX : Analyseur Syntaxique  \
\n make clean  \
\n make all"

CC=gcc
CFLAGS = -Wall -I. -Wno-unused-function
LEX=flex
LFLAGS= 
YACC=bison -d
YFLAGS= 

## default = help
usage :
	@echo -e ${USAGE}

## exemple d'integration de Code C externe aux specs
mon_analyseur : EXT_SRC = mes_extras.c ma_librairie.c -lm

## regles implicites : XX.flex XX.bison => XX | lex-XX | parse-XX
%  parse-% :: %.bison %.flex 
	@echo "Analyseur Syntaxique : $*.bison $*.flex $(EXT_SRC) ==> $@"
	$(LEX)  $(LFLAGS) -o yylex.c   $*.flex
	$(YACC) $(YFLAGS) -o yyparse.c $*.bison
	$(CC)   $(CFLAGS) -o $@  yylex.c yyparse.c $(EXT_SRC)

%  lex-% :: %.flex  
	@echo "Analyseur Lexical : $*.flex $(EXT_SRC) ==> $@"
	$(LEX)  $(LFLAGS) -o yylex.c  $*.flex
	$(CC)   $(CFLAGS) -DFLEXALONE -o $@  yylex.c $(EXT_SRC)

## clean  
SPEC=$(wildcard *.flex)   # ~> exec to be cleaned
clean :
	-rm -f yylex.c yyparse.c yyparse.h 
	-rm -f *.o *~ a.out lex.yy.c
	-rm -f $(SPEC:%.flex=%) $(SPEC:%.flex=lex-%) $(SPEC:%.flex=parse-%)

## all  = make XXX for all existing XXX.flex
all : $(SPEC:%.flex=%)

#local
calc4 : EXT_SRC = -lm
calc5 : EXT_SRC = -lm
calc-AST : EXT_SRC = arbre.c
calc-symtab : EXT_SRC = symtab.c -lm
