%{
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "yyparse.h"
extern FILE *yyin;
#define MAX_ELEMENT 1024
#define NB_BLOCKS ((MAX_ELEMENT+63)/64)
extern unsigned long long* set_create();

static unsigned long long* parseSet(const char *s) {
    unsigned long long* set = set_create();
    const char *p = s;
    if (*p == '{') p++;
    while (*p && *p != '}') {
        while (*p && !isdigit(*p)) p++;
        if (*p == '}' || *p == '\0') break;
        int num = atoi(p);
        if (num >= 1 && num <= MAX_ELEMENT) {
            int block = (num-1) / 64;
            int bit = (num-1) % 64;
            set[block] |= (1ULL << bit);
        }
        while (*p && isdigit(*p)) p++;
    }
    return set;
}

static void printError(const char *s) {
    fprintf(stderr, "Lexical error: %s\n", s);
}
%}

%option noyywrap nounput

SET_LITERAL   \{[0-9]+(,[0-9]+)*\}
EMPTY_SET     \{\}
CARD_WORD     ([cC][aA][rR][dD])

%%
"union"       { return UNION; }
"inter"       { return INTER; }
"comp"        { return COMP; }
":="          { return ASSIGN; }
"-"           { return MINUS; }
{CARD_WORD}   { return CARD; }
[A-Za-z][A-Za-z0-9]*  { yylval.id = strdup(yytext); return IDENT; }
{SET_LITERAL} { yylval.set = parseSet(yytext); return SET; }
{EMPTY_SET}   { yylval.set = set_create(); return SET; }
"="           { return '='; }
"("           { return '('; }
")"           { return ')'; }
[ \t\r]+     { }
\n           { return '\n'; }
.            { printError("Caractère inattendu"); }
%%

