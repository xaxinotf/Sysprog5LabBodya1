%option noyywrap
%{
#include "parser.tab.h"
#include <string.h>
%}

digit   [0-9]
letter  [A-Za-z]
id      {letter}({letter}|{digit})*

%%
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return MULTIPLY; }
"/"             { return DIVIDE; }
","             { return COMMA; }
"int"           { return INT; }
"return"        { return RETURN; }
{id}            { yylval.strval = strdup(yytext); return IDENTIFIER; }
{digit}+        { yylval.intval = atoi(yytext); return NUMBER; }
";"             { return SEMICOLON; }
"="             { return ASSIGN; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"("             { return LPAREN; }
")"             { return RPAREN; }
\n              { extern int line_num; line_num++; }
[ \t]           { /* ignore whitespace */ }
.               { printf("Unexpected character: %s\n", yytext); }
%%
