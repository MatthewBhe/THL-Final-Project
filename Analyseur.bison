%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

#define UNIVERSAL_SET (((unsigned long long)-1) & ~1ULL)

typedef struct Symbol {
    char *name;
    unsigned long long set;
    int defined;
    struct Symbol *next;
} Symbol;

Symbol *symbolTable = NULL;

Symbol* lookup(const char *name) {
    Symbol *s = symbolTable;
    while(s) {
         if(strcmp(s->name, name) == 0)
             return s;
         s = s->next;
    }
    s = (Symbol*)malloc(sizeof(Symbol));
    s->name = strdup(name);
    s->set = 0;
    s->defined = 0;
    s->next = symbolTable;
    symbolTable = s;
    return s;
}

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
    char* id;
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
           free($1);
      }
    | IDENT ASSIGN set_expr {
           Symbol *sym = lookup($1);
           sym->set = $3;
           sym->defined = 1;
           printf("%s = ", sym->name);
           printSet(sym->set);
           printf("\n");
           free($1);
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
           Symbol *sym = lookup($1);
           if (!sym->defined) {
               printError("Variable non définie");
               $$ = 0;
           } else {
               $$ = sym->set;
           }
           free($1);
      }
    | '(' set_expr ')' { $$ = $2; }
    ;

%%

int main(void) {
    yyparse();
    return 0;
}

int yyerror(const char *s) {
    printError(s);
    return 0;
}

