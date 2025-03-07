%{
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#define MAX_ELEMENT 1024
#define NB_BLOCKS ((MAX_ELEMENT+63)/64)

typedef struct Symbol {
    char *name;
    unsigned long long* set;
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
    s = malloc(sizeof(Symbol));
    s->name = strdup(name);
    s->set = malloc(NB_BLOCKS * sizeof(unsigned long long));
    for (int i = 0; i < NB_BLOCKS; i++) s->set[i] = 0;
    s->defined = 0;
    s->next = symbolTable;
    symbolTable = s;
    return s;
}

unsigned long long* set_create() {
    unsigned long long* s = malloc(NB_BLOCKS * sizeof(unsigned long long));
    for (int i = 0; i < NB_BLOCKS; i++)
        s[i] = 0;
    return s;
}

unsigned long long* set_copy(unsigned long long* a) {
    unsigned long long* s = malloc(NB_BLOCKS * sizeof(unsigned long long));
    for (int i = 0; i < NB_BLOCKS; i++)
         s[i] = a[i];
    return s;
}

unsigned long long* set_union(unsigned long long* a, unsigned long long* b) {
    unsigned long long* s = set_create();
    for (int i = 0; i < NB_BLOCKS; i++)
         s[i] = a[i] | b[i];
    return s;
}

unsigned long long* set_intersect(unsigned long long* a, unsigned long long* b) {
    unsigned long long* s = set_create();
    for (int i = 0; i < NB_BLOCKS; i++)
         s[i] = a[i] & b[i];
    return s;
}

unsigned long long* set_difference(unsigned long long* a, unsigned long long* b) {
    unsigned long long* s = set_create();
    for (int i = 0; i < NB_BLOCKS; i++)
         s[i] = a[i] & ~(b[i]);
    return s;
}

int countBits(unsigned long long* s) {
    int count = 0;
    for (int i = 0; i < NB_BLOCKS; i++) {
         unsigned long long block = s[i];
         while (block) {
             count += block & 1;
             block >>= 1;
         }
    }
    return count;
}

void printSet(unsigned long long* s) {
    int first = 1;
    printf("{");
    for (int num = 1; num <= MAX_ELEMENT; num++) {
         int block = (num-1) / 64;
         int bit = (num-1) % 64;
         if(s[block] & (1ULL << bit)) {
             if(!first)
                printf(",");
             printf("%d", num);
             first = 0;
         }
    }
    printf("}");
}

int set_equal(unsigned long long* a, unsigned long long* b) {
    for (int i = 0; i < NB_BLOCKS; i++) {
         if(a[i] != b[i])
              return 0;
    }
    return 1;
}

int set_inclusion(unsigned long long* a, unsigned long long* b) {
    for (int i = 0; i < NB_BLOCKS; i++) {
         if(a[i] & ~(b[i]))
              return 0;
    }
    return 1;
}

void printError(const char *s) {
    fprintf(stderr, "Syntax error: %s\n", s);
}

extern int yylex(void);
int yyerror(const char *s);
%}

%union {
    unsigned long long* set;
    char* id;
}

%token <id> IDENT
%token ASSIGN
%token <set> SET
%token UNION
%token MUNION
%token INTER
%token COMP
%token MINUS
%token CARD
%token IN

%type <set> set_expr union_expr intersect_expr diff_expr primary card_expr
%type <set> set_expr_list multi_union_expr

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
      IDENT ASSIGN card_expr %prec ASSIGN { printError("Impossible d'affecter une valeur numérique à un ensemble."); free($1); }
    | IDENT ASSIGN set_expr { Symbol *sym = lookup($1); if(sym->defined) { free(sym->set); } sym->set = $3; sym->defined = 1; printf("%s = ", sym->name); printSet(sym->set); printf("\n"); free($1); }
    | set_expr { printSet($1); printf("\n"); }
    | card_expr { int card = countBits($1); printf("%d\n", card); }
    | set_expr '=' set_expr { if(set_equal($1, $3)) printf("true\n"); else printf("false\n"); free($1); free($3); }
    | set_expr IN set_expr { if(set_inclusion($1, $3)) printf("true\n"); else printf("false\n"); free($1); free($3); }
    | multi_union_expr { printSet($1); printf("\n"); free($1); }
    ;

card_expr:
      CARD set_expr { $$ = $2; }
    ;

set_expr:
      union_expr
    ;

union_expr:
      union_expr UNION intersect_expr { unsigned long long* tmp = set_union($1, $3); free($1); free($3); $$ = tmp; }
    | intersect_expr { $$ = $1; }
    ;

intersect_expr:
      intersect_expr INTER diff_expr { unsigned long long* tmp = set_intersect($1, $3); free($1); free($3); $$ = tmp; }
    | intersect_expr MINUS diff_expr { unsigned long long* tmp = set_difference($1, $3); free($1); free($3); $$ = tmp; }
    | diff_expr { $$ = $1; }
    ;

diff_expr:
      diff_expr COMP primary { unsigned long long* tmp = set_difference($1, $3); free($1); free($3); $$ = tmp; }
    | primary { $$ = $1; }
    ;

primary:
      SET { $$ = $1; }
    | IDENT { Symbol *sym = lookup($1); if (!sym->defined) { printError("Variable non définie"); $$ = set_create(); } else { $$ = set_copy(sym->set); } free($1); }
    | '(' set_expr ')' { $$ = $2; }
    | multi_union_expr { $$ = $1; }
    ;

/* Production pour union multiple sous forme d'une instruction complète */
set_expr_list:
      set_expr { $$ = $1; }
    | set_expr_list ',' set_expr { unsigned long long* tmp = set_union($1, $3); free($1); $$ = tmp; }
    ;

multi_union_expr:
      MUNION set_expr_list ')' { $$ = $2; }
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

