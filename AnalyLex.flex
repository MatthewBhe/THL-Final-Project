%{
#include "yyparse.h"
#include <stdlib.h>
#include <stdio.h>
#include <ctype.h>
extern FILE *yyin;

#define COLOR_IDENT   "\033[32m"   /* Vert */
#define COLOR_ASSIGN  "\033[36m"   /* Cyan */
#define COLOR_SET     "\033[33m"   /* Jaune */
#define COLOR_OPER    "\033[34m"   /* Bleu */
#define COLOR_MINUS   "\033[31m"   /* Rouge */
#define COLOR_NUM     "\033[37m"   /* Blanc */
#define COLOR_RESET   "\033[0m"

int card_mode = 0;

void printError(const char *s) {
    fprintf(stderr, "Lexical error: %s\n", s);
}

int countElements(const char *set) {
    int count = 0;
    const char *p = set + 1;
    while (*p && *p != '}') {
        while (*p && isspace(*p)) p++; 
        if (*p == '}' || *p == '\0')
            break;
        count++;
        while (*p && *p != ',' && *p != '}') p++;
        if (*p == ',') p++;
    }
    return count;
}
%}

%option noyywrap nounput
%x CARD

SET_LITERAL   \{[0-9]+(,[0-9]+)*\}
EMPTY_SET     \{\}
CARD_WORD     ([cC][aA][rR][dD])

%%
{CARD_WORD}         { card_mode = 1; }
"union"             { printf(COLOR_OPER "TOKEN_UNION " COLOR_RESET); }
"inter"             { printf(COLOR_OPER "TOKEN_INTER " COLOR_RESET); }
"comp"              { printf(COLOR_OPER "TOKEN_COMP " COLOR_RESET); }
":="                { printf(COLOR_ASSIGN "TOKEN_ASSIGN " COLOR_RESET); }
"-"                 { printf(COLOR_MINUS "TOKEN_MINUS " COLOR_RESET); }
[A-Za-z]            { printf(COLOR_IDENT "TOKEN_IDENT %c " COLOR_RESET, toupper(yytext[0])); }
{SET_LITERAL}       { printf(COLOR_SET "TOKEN_SET %s" COLOR_RESET, yytext); }
{EMPTY_SET}         { printf(COLOR_SET "TOKEN_SET {}" COLOR_RESET); }
[0-9]+              { printf(COLOR_NUM "%s " COLOR_RESET, yytext); }
","                 { printf(","); }
[ \t\r]+	    { }
\n                  { printf("\n"); }
.                   {}

<CARD>{SET_LITERAL} { printf(COLOR_SET "%d" COLOR_RESET, countElements(yytext)); BEGIN(INITIAL); }
<CARD>{EMPTY_SET}   { printf("0"); BEGIN(INITIAL); }
<CARD>[ \t\r\n]+    {}
<CARD>.             {}

%%

int main(void) {
    yylex();
    return 0;
}

