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

%type <set> set_expr union_expr intersect_expr diff_expr primary card_expr

%left UNION
%left INTER MINUS
%left COMP
%nonassoc ASSIGN

%%

input:
      | input line
    ;

line:
      '\n'
    | stmt '\n'
    ;

stmt:
      IDENT ASSIGN card_expr %prec ASSIGN {
           printError("Impossible d'affecter une valeur numérique à un ensemble.");
      }
    | IDENT ASSIGN set_expr {
           symbol[(int)$1] = $3;
           defined[(int)$1] = 1;
           printf("%c = ", $1);
           printSet(symbol[(int)$1]);
           printf("\n");
      }
    | set_expr {
           printSet($1);
           printf("\n");
      }
    | card_expr {
           int card = countBits($1);
           printf("%d\n", card);
      }
    ;

card_expr:
      CARD set_expr {
           $$ = $2;
      }
    ;

set_expr: union_expr ;

union_expr:
      union_expr UNION intersect_expr { $$ = $1 | $3; }
    | intersect_expr { $$ = $1; }
    ;

intersect_expr:
      intersect_expr INTER diff_expr { $$ = $1 & $3; }
    | intersect_expr MINUS diff_expr { $$ = $1 & ~($3); }
    | diff_expr { $$ = $1; }
    ;

diff_expr:
      diff_expr COMP primary { $$ = $1 & ~($3); }
    | primary { $$ = $1; }
    ;

primary:
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

