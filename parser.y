%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_VARIABLES 256
int variables[MAX_VARIABLES];

int yylex(void);
void yyerror(const char *s);

int line_num = 1;
extern FILE *yyin;

int variable_index(char *var) {
    return var[0] - 'a'; // Simple function for example purposes
}

void set_variable(char *var, int value) {
    int idx = variable_index(var);
    if(idx >= 0 && idx < MAX_VARIABLES) {
        variables[idx] = value;
    } else {
        fprintf(stderr, "Variable index out of range: %s\n", var);
    }
}

int get_variable(char *var) {
    int idx = variable_index(var);
    if(idx >= 0 && idx < MAX_VARIABLES) {
        return variables[idx];
    } else {
        fprintf(stderr, "Variable index out of range: %s\n", var);
        return 0;
    }
}

%}

%union {
    int intval;
    char* strval;
}

%token <strval> IDENTIFIER
%token <intval> NUMBER
%token INT RETURN SEMICOLON ASSIGN LBRACE RBRACE LPAREN RPAREN COMMA PLUS MINUS MULTIPLY DIVIDE

%type <intval> expression
%type <strval> identifier_list
%type <intval> declaration statement statement_list

%%

program:
    function
    ;

function:
    INT IDENTIFIER LPAREN RPAREN LBRACE declaration_list statement_list RBRACE
    ;

declaration_list:
    /* empty */
    | declaration_list declaration SEMICOLON
    ;

declaration:
    INT identifier_list
    ;

identifier_list:
    IDENTIFIER { printf("Line number %d\tdeclaration %s\ttype INT\n", line_num, $1); }
    | identifier_list COMMA IDENTIFIER { printf("Line number %d\tdeclaration %s\ttype INT\n", line_num, $3); }
    | IDENTIFIER ASSIGN expression {
        printf("Line number %d\tdeclaration %s\ttype INT with initialization\tvalue %d\n", line_num, $1, $3);
        set_variable($1, $3);
    }
    ;

statement_list:
    /* empty */
    | statement_list statement
    ;

statement:
    IDENTIFIER ASSIGN expression SEMICOLON {
        set_variable($1, $3); // Store the value in the symbol table
        printf("Line number %d\tassignment to %s\tvalue %d\n", line_num, $1, $3);
    }
    | RETURN expression SEMICOLON {
        printf("Line number %d\treturn statement\tvalue %d\n", line_num, $2);
    }
    ;

expression:
    NUMBER {
        $$ = $1;
    }
    | IDENTIFIER {
        $$ = get_variable($1); // Retrieve the value from the symbol table
    }
    | expression PLUS expression { $$ = $1 + $3; }
    | expression MINUS expression { $$ = $1 - $3; }
    | expression MULTIPLY expression { $$ = $1 * $3; }
    | expression DIVIDE expression {
        if ($3 == 0) {
            yyerror("division by zero");
            $$ = 0;
        } else {
            $$ = $1 / $3;
        }
    }
    | LPAREN expression RPAREN { $$ = $2; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s at line %d\n", s, line_num);
}

int main(void) {
    char filename[256]; // Buffer to store the filename

    printf("Enter the path to the file: ");
    fflush(stdout); // Ensure 'Enter the path to the file: ' is printed before scanf

    if (scanf("%255s", filename) != 1) {
        fprintf(stderr, "Error reading the file path.\n");
        return 1;
    }

    FILE *file = fopen(filename, "r");
    if (!file) {
        perror(filename);
        return 1;
    }

    yyin = file;
    yyparse();
    fclose(file);

    return 0;
}
