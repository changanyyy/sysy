%{
# include <cerrno>
# include <climits>
# include <cstdlib>
# include <cstring> // strerror
# include <string>
# include "driver.hpp"
# include "parser.hpp"

#undef  YY_DECL
#define YY_DECL int grammar::Scanner::yylex( grammar::SysyParser::semantic_type * const lval, grammar::SysyParser::location_type *loc )

/* typedef to make the returns for the tokens shorter */
using token = grammar::Parser::token;

/* define yyterminate as this instead of NULL */
#define yyterminate() return( token::END )

/* msvc2010 requires that we exclude this header file. */
#define YY_NO_UNISTD_H

/* update location on matching */
#define YY_USER_ACTION loc->step(); loc->columns(yyleng);

%}

%option debug
%option nodefault
%option yyclass="grammar::SysyScanner"
%option noyywrap
%option c++

r_white         [ \t\n\r]
r_digit         [0-9]
r_letter        [a-zA-Z]
r_semi          ";"
r_comma         ","
r_assignop      "="
r_const         "const"
r_if            "if"
r_else          "else"
r_while         "while"
r_break         "break"
r_continue      "continue"
r_return        "return"
r_plus          "+"
r_minus         "-"
r_mul           "*"
r_div           "/"
r_mod           "%"
r_not           "!"
r_gt            ">"
r_lt            "<"
r_ge            ">="
r_le            "<="
r_eq            "=="
r_ne            "!="
r_and           "&&"
r_or            "||"
r_lp            "("             
r_rp            ")"            
r_lb            "["           
r_rb            "]"          
r_lc            "{"               
r_rc            "}"
r_int           "int"
r_float         "float"
r_void          "void"
r_ident         (_|{r_letter})(_|{r_letter}|{r_digit})*
r_intconst      ([1-9]{r_digit}*)|("0"[xX]({r_letter}|{r_digit})*)|("0"{r_digit}+)|0
r_floatconst    ({r_digit}+\.{r_digit}+)|((({r_digit}*\.{r_digit}+)|({r_digit}+\.{r_digit}*))[Ee][+-]?{r_digit}+)

r_other         .
r_comment       ("//"[^\n]*)|("/*"([^\*]|(\*)*[^\*/])*(\*)*"*/")
r_err_comment   "/*"([^\*]|(\*)*[^\*/])*(\*)*



%%
%{          /** Code executed at the beginning of yylex **/
            yylval = lval;
%}

[a-z]       {
               return( token::LOWER );
            }

[A-Z]       {
               return( token::UPPER );
            }

[a-zA-Z]+   {
               /**
                * Section 10.1.5.1 of the 3.0.2 Bison Manual says the 
                * following should work:
                * yylval.build( yytext );
                * but it doesn't.
                * ref: http://goo.gl/KLn0w2
                */
               yylval->build< std::string >( yytext );
               return( token::WORD );
            }

\n          {
               // Update line number
               loc->lines();
               return( token::NEWLINE );
            }

.           {
               return( token::CHAR );
            }
{r_white}       { }
{r_semi}        { yylval.node = new Node("SEMI", yylineno, 0);              return SEMI;        }
{r_comma}       { yylval.node = new Node("COMMA", yylineno, 0);             return COMMA;       }
{r_assignop}    { yylval.node = new Node("ASSIGNOP", yylineno, 0);          return ASSIGNOP;    }
{r_const}       { yylval.node = new Node("CONST", yylineno, 0);             return CONST;          }
{r_if}          { yylval.node = new Node("IF", yylineno, 0);                return IF;          }
{r_else}        { yylval.node = new Node("ELSE", yylineno, 0);              return ELSE;        }
{r_while}       { yylval.node = new Node("WHILE", yylineno, 0);             return WHILE;       }
{r_break}       { yylval.node = new Node("BREAK", yylineno, 0);             return BREAK;       }
{r_continue}    { yylval.node = new Node("CONTINUE", yylineno, 0);          return CONTINUE;    }
{r_return}      { yylval.node = new Node("RETURN", yylineno, 0);            return RETURN;      }
{r_plus}        { yylval.node = new Node("PLUS", yylineno, 0);              return PLUS;        }
{r_minus}       { yylval.node = new Node("MINUS", yylineno, 0);             return MINUS;       }
{r_mul}         { yylval.node = new Node("MUL", yylineno, 0);               return MUL;         }
{r_div}         { yylval.node = new Node("DIV", yylineno, 0);               return DIV;         }
{r_mod}         { yylval.node = new Node("MOD", yylineno, 0);               return MOD;         }
{r_not}         { yylval.node = new Node("NOT", yylineno, 0);               return NOT;         }
{r_gt}          { yylval.node = new Node("GT", yylineno, 0);                return GT;          }
{r_lt}          { yylval.node = new Node("LT", yylineno, 0);                return LT;          }
{r_ge}          { yylval.node = new Node("GE", yylineno, 0);                return GE;          }
{r_le}          { yylval.node = new Node("LE", yylineno, 0);                return LE;          }
{r_eq}          { yylval.node = new Node("EQ", yylineno, 0);                return EQ;          }
{r_ne}          { yylval.node = new Node("NE", yylineno, 0);                return NE;          }
{r_and}         { yylval.node = new Node("AND", yylineno, 0);               return AND;         }
{r_or}          { yylval.node = new Node("OR", yylineno, 0);                return OR;          }
{r_lp}          { yylval.node = new Node("LP", yylineno, 0);                return LP;          }           
{r_rp}          { yylval.node = new Node("RP", yylineno, 0);                return RP;          }            
{r_lb}          { yylval.node = new Node("LB", yylineno, 0);                return LB;          }           
{r_rb}          { yylval.node = new Node("RB", yylineno, 0);                return RB;          }         
{r_lc}          { yylval.node = new Node("LC", yylineno, 0);                return LC;          }             
{r_rc}          { yylval.node = new Node("RC", yylineno, 0);                return RC;          }
{r_int}         { yylval.node = new Node("INT", yylineno, 0);               return INT;         }
{r_float}       { yylval.node = new Node("FLOAT", yylineno, 0);             return FLOAT;       }
{r_void}        { yylval.node = new Node("VOID", yylineno, 0);              return VOID;        }
{r_ident}       { yylval.node = new Node("IDENT", yylineno, 0, yytext);     return IDENT;          }
{r_intconst}    {
                    //std::cout<<"123"<<std::endl;
                    int zero_flag = 1;
                    int idx = 0;
                    while(yytext[idx]!='\0'){
                        if(yytext[idx]!='x' && yytext[idx]!='X' && yytext[idx]!='0')zero_flag = 0;
                        idx++;
                    }
                    //if the INT is 0
                    if(strcmp(yytext, "0") == 0 || strcmp(yytext, "0x0") == 0 || strcmp(yytext, "00") == 0 || zero_flag){
                        yylval.node = new Node("INTCONST", yylineno, 0, 0);
                        return INTCONST;
                    }

                    //tanslate string to int
                    long int ret = 0;
                    char *end;
                    ret = strtol(yytext, &end, 0);
                    if(ret == 0L || end - yytext < yyleng){
                        
                        print_lexical_error();
                    }
                    //it's OK
                    yylval.node = new Node("INTCONST", yylineno, 0, ret);
                    return INTCONST;
                }
{r_floatconst}  {
                    int zero_flag = 1;
                    int idx = 0;
                    while(yytext[idx]!='\0'){
                        if(yytext[idx]!='e' && yytext[idx]!='E' && yytext[idx]!='.' && yytext[idx]!='0')
                            zero_flag = 0;
                        idx++;
                    }
                    if(strcmp(yytext, "0") == 0 || strcmp(yytext, "0.0") == 0 || zero_flag)
                    {
                        yylval.node = new Node("FLOATCONST", yylineno, 0, 0.0);
                        return FLOATCONST;
                    }
                    double ret = 0;
                    int res;
                    char *end;
                    res = sscanf(yytext,"%lf",&ret);
                    if(res<=0)
                        print_lexical_error();
                    yylval.node = new Node("FLOATCONST", yylineno, 0, ret);
                    return FLOATCONST;
                }
<<EOF>>         { yyterminate();                                                                }
{r_comment}     {                                                                               }
{r_err_comment} { print_lexical_error();                                                        }
{r_other}       { print_lexical_error();                                                        }


%%
