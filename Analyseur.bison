%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#define UNIVERSAL_SET (((unsigned long long)-1) & ~1ULL)
unsigned long long symbol[128];
int defined[128] = {0};
int countBits(unsigned long long set) {
    int count = 0;
    while (set) {
        count += set & 1;
        set >>= 1;
    }
    return count;
}
void printSet(unsigned long long set) {
    int first = 1;
    printf("{");
    for (int i = 1; i < 64; i++) {
        if (set & (1ULL << i)) {
            if (!first)
                printf(",");
            printf("%d", i);
            first = 0;
        }
    }
    printf("}");
}
void printError(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}
extern int yylex(void);
int yyerror(const char *s);
%}

%union {
    unsigned long long set;
    int intval;
    char id;
}

%token <id> IDENT
%token ASSIGN
%token <set> SET
%token UNION
%token INTER
%token COMP
%token MINUS
%token CARD

%type <set> set_expr term factor

%left UNION
%left INTER
%left MINUS
%right COMP

%%

input:
      | input line
    ;

line:
      '\n'
    | stmt '\n'
    ;

stmt:
      IDENT ASSIGN IDENT {
           if (!defined[(int)$3]) {
              printError("Variable non définie");
           } else {
              symbol[(int)$1] = symbol[(int)$3];
              defined[(int)$1] = 1;
              printf("%c = ", $1);
              printSet(symbol[(int)$1]);
              printf("\n");
           }
      }
    | IDENT ASSIGN set_expr {
           symbol[(int)$1] = $3;
           defined[(int)$1] = 1;
           printf("Expression syntaxiquement correcte.\n");
      }
    | set_expr {
           printf("Expression syntaxiquement correcte.\n");
      }
    | card_expr
    ;

card_expr:
      CARD set_expr {
           int card = countBits($2);
           printf("%d\n", card);
      }
    ;

set_expr:
      set_expr UNION term { $$ = $1 | $3; }
    | set_expr INTER term { $$ = $1 & $3; }
    | set_expr MINUS term { $$ = $1 & ~($3); }
    | term { $$ = $1; }
    ;

term:
      COMP term { $$ = UNIVERSAL_SET & ~($2); }
    | factor { $$ = $1; }
    ;

factor:
      SET { $$ = $1; }
    | IDENT { 
           if (!defined[(int)$1]) {
               printError("Variable non définie");
               $$ = 0;
           } else {
               $$ = symbol[(int)$1];
           }
      }
    | '(' set_expr ')' { $$ = $2; }
    ;

%%

int main(void) {
    for (int i = 0; i < 128; i++) {
        symbol[i] = 0;
        defined[i] = 0;
    }
    yyparse();
    return 0;
}

int yyerror(const char *s) {
    printError(s);
    return 0;
}

