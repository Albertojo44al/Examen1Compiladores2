%{
    #include <cstdio>
    #include <fstream>
    #include <map>
    #include <iostream>
    using namespace std;
    int yylex();
    extern int yylineno;

     map<string, float> variables;
    void yyerror(const char * s){
        fprintf(stderr, "Line: %d, error: %s\n", yylineno, s);
    }

    #define YYERROR_VERBOSE 1
%}

%union{
   const char* string_t;
   float float_t;
   bool bool_t;
}

%token TK_PRINT TK_IF TK_LET TK_BEGIN TK_END TK_RETURN TK_ASIGNATION TK_PLUS
%token TK_MINUS TK_DIV TK_MULTI TK_EQUAL TK_LESS TK_GREATER
%token<float_t> TK_LIT_FLOAT 
%token <string_t> TK_ID
%type<float_t>logical_expr term factor expr method_expresion params ;
%%

program: statements
;

statements: statements statement
          | statement 
          ;

statement: TK_PRINT '(' params ')' ';' { printf("%f\n", $3); }
          | if_statement
          | assignation_statement 
          | return_statement
          ;

return_statement: TK_RETURN logical_expr ';'

if_statement: TK_IF '(' logical_expr ')' TK_BEGIN statements TK_END 
            ;

assignation_statement : TK_LET TK_ID TK_ASIGNATION params ';'{variables.insert(make_pair($2, $4));}
            |   TK_LET TK_ID '(' params ')' TK_ASIGNATION method_expresion 
                ;

params: params ',' logical_expr
    | logical_expr
    ; 

method_expresion :  TK_BEGIN statements TK_END
    ; 

logical_expr: logical_expr TK_GREATER logical_expr { $$ = (float)($1 > $3);}
    |   logical_expr TK_LESS logical_expr { $$ = (float)($1 < $3);}
    |   logical_expr TK_EQUAL logical_expr { $$ = (float)($1 == $3);}
    |   expr {$$ = $1; }
    ;

expr: expr TK_PLUS factor {$$ = $1 + $3; }
    | expr TK_MINUS factor {$$ = $1 - $3; }
    | factor {$$ = $1; }
    ;

factor: factor TK_MULTI term {$$ = $1 * $3; }
    | factor TK_DIV term {$$ = $1 / $3; }
    | term {$$ = $1; }
    ;

term: TK_LIT_FLOAT {$$ = $1;}
    | TK_ID {if(variables.count($1)){$$ = variables.find($1)->second;} else {printf("Variable %s no está declarada\n",$1); return 0;}}
    ;
 

%%
