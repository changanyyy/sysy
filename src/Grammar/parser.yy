%skeleton "lalr1.cc"
%require  "3.5"
%language "c++"
%header
%locations
%debug 
%defines 
%define api.namespace {grammar}
%define api.parser.class {Parser}
%define api.token.constructor
%define parse.assert

%code requires{

namespace grammar {
   class Driver;
   class Scanner;
}

// The following definitions is missing when %locations isn't used
# ifndef YY_NULLPTR
#  if defined __cplusplus && 201103L <= __cplusplus
#   define YY_NULLPTR nullptr
#  else
#   define YY_NULLPTR 0
#  endif
# endif

}

%parse-param { SysyScanner &scanner }
%parse-param { SysyDriver  &driver  }

%locations

%code{
#include <iostream>
#include <cstdlib>
#include <string>
#include <fstream>
#include "driver.hpp"
#include "ASTNode.hpp"
#undef yylex
#define yylex scanner.yylex
}


%define api.value.type variant
%define api.token.prefix {TOK_}

%token END
%token ASSIGNOP  SEMI      COMMA
%token IF        ELSE      WHILE     BREAK     CONTINUE  RETURN
%token PLUS      MINUS     MUL       DIV       MOD
%token NOT       GT        LT        GE        LE        EQ        NE        AND       OR
%token LP        RP        LB        RB        LC        RC
%token INT       FLOAT     VOID      CONST                 
%token <std::string>  IDENT   
%token <int>          INTCONST    
%token <float>        FLOATCONST

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE



%type <UniPtrVec<GloDef>> CompUnit
%type <EnumType> BType
%type <UniPtrVec<GloDef>>  GlobalDecl
%type <UniPtrVec<ConstDef>> ConstantDecl 
%type <UniPtrVec<VarDef>> VariableDecl
%type <UniPtr<FuncDef>> FunctionDecl
%type <UniPtrVec<ConstDef>> ConstantDefList
%type <UniPtrVec<VarDef>> VariableDefList
%type <UniPtr<ConstDef>> ConstantDef
%type <UniPtr<ConstDef>> VariableDef


%type <node>    ConstDef        ConstDef2
%type <node>    ConstInitVal    ConstInitVal2
%type <node>    VarDecl         VarDecl2
%type <node>    VarDef          VarDef2
%type <node>    InitVal         InitVal2
%type <node>    FuncDef
%type <node>    FuncFParams     FuncFParams2
%type <node>    FuncFParam       FuncFParam2
%type <node>    Block           Block2
%type <node>    BlockItem
%type <node>    Stmt
%type <node>    Exp
%type <node>    Cond
%type <node>    LVal            LVal2
%type <node>    PrimaryExp
%type <node>    Number
%type <node>    UnaryExp
%type <node>    UnaryOp
%type <node>    FuncRParams     FuncRParams2
%type <node>    MulExp
%type <node>    AddExp          
%type <node>    RelExp
%type <node>    EqExp
%type <node>    LAndExp
%type <node>    LOrExp
%type <node>    ConstExp

%start Program

%%

Program:
  CompUnit END {
    $$ = make_shared<Unit>($1);
  };

//1.???????????? 
CompUnit:
  CompUnit GlobalDecl {
    $1.push_back(Ptr<GlobalDecl>($2));
    $$ = $1;
  }
  | %empty {
    $$ = {};
  };

GlobalDecl:
  ConstantDecl {
    $$ = PtrVec<GloDef>();
    $$.insert($$.end(), $1.begin(), $1.end());
  }
  | VariableDecl {
    $$ = PtrVec<GloDef>();
    $$.insert($$.end(), $1.begin(), $1.end());
  }
  | FunctionDecl {
    $$ = UniPtrVector<GloDef>();
    $$.push_back($1);
  };
  
ConstantDecl: 
  CONST BType ConstantDefList SEMI {
    for(auto &def: $3){
      def.setBType($2);
    }
    $$ = $3;
  };

ConstantDefList:
  ConstantDef {
    $$ = PtrVec<ConstDef>();
    $$.push_back($1);
  }
  | ConstantDefList COMMA ConstantDef {
    $1.push_back($3);
    $$ = $1;
  };

VariableDecl: 
  CONST BType VariableDefList SEMI {
    for(auto &def: $3){
      def.setBType($2);
    }
    $$ = $3;
  };

VariableDefList:
  VariableDef {
    $$ = PtrVec<VariableDef>();
    $$.push_back($1);
  }
  | VariableDefList COMMA VariableDef {
    $1.push_back($3);
    $$ = $1;
  };

BType: 
  INT { $$ = EnumType::I32; }
 	| FLOAT { $$ = EnumType::FLOAT; };







//5.????????????
ConstDef: IDENT ConstDef2 ASSIGNOP ConstInitVal     { $$ = new Node("ConstDef", @$.first_line, 4, $1, $2, $3, $4); }
        ;
ConstDef2: ConstDef2 LB ConstExp RB                 { $$ = new Node("ConstDef2", @$.first_line, 4, $1, $2, $3, $4); }
		 |                                          { $$ = new Node("ConstDef2", @$.first_line, 0); }
         ;

//6.????????????
ConstInitVal: ConstExp                              { $$ = new Node("ConstInitVal", @$.first_line, 1, $1); }
			| LC ConstInitVal ConstInitVal2 RC      { $$ = new Node("ConstInitVal", @$.first_line, 4, $1, $2, $3, $4); }
			| LC RC                                 { $$ = new Node("ConstInitVal", @$.first_line, 2, $1, $2); }
            ;
ConstInitVal2: COMMA ConstInitVal ConstInitVal2     { $$ = new Node("ConstInitVal2", @$.first_line, 3, $1, $2, $3); }
			|                                       { $$ = new Node("ConstInitVal2", @$.first_line, 0); }
			;

//7.????????????
VarDecl: BType VarDef VarDecl2 SEMI                 { $$ = new Node("VarDecl", @$.first_line, 4, $1, $2, $3, $4); }
       ;
VarDecl2: COMMA VarDef VarDecl2                     { $$ = new Node("VarDecl2", @$.first_line, 3, $1, $2, $3); }
		|                                           { $$ = new Node("VarDecl2", @$.first_line, 0); }
        ;

//8.????????????
VarDef: IDENT VarDef2                               { $$ = new Node("VarDef", @$.first_line, 2, $1, $2); }
	  | IDENT VarDef2 ASSIGNOP InitVal              { $$ = new Node("VarDef", @$.first_line, 4, $1, $2, $3, $4); }
      ;
VarDef2: LB ConstExp RB VarDef2                     { $$ = new Node("VarDef2", @$.first_line, 4, $1, $2, $3, $4); }
	   |                                            { $$ = new Node("VarDef2", @$.first_line, 0); }
       ;

//9.????????????
InitVal: Exp                                        { $$ = new Node("InitVal", @$.first_line, 1, $1); }
       | LC InitVal InitVal2 RC                     { $$ = new Node("InitVal", @$.first_line, 4, $1, $2, $3, $4); }
       | LC RC                                      { $$ = new Node("InitVal", @$.first_line, 2, $1, $2); }
       ;
InitVal2: COMMA InitVal InitVal2                    { $$ = new Node("InitVal2", @$.first_line, 3, $1, $2, $3); }
		|                                           { $$ = new Node("InitVal2", @$.first_line, 0); }
        ;

//10.???????????? ?????????FuncType??????
FuncDef: VOID IDENT LP FuncFParams RP Block         { $$ = new Node("FuncDef", @$.first_line, 6, $1, $2, $3, $4, $5, $6); }
       | BType IDENT LP FuncFParams RP Block        { $$ = new Node("FuncDef", @$.first_line, 6, $1, $2, $3, $4, $5, $6); }
       | VOID IDENT LP RP Block                     { $$ = new Node("FuncDef", @$.first_line, 5, $1, $2, $3, $4, $5); }
       | BType IDENT LP RP Block                    { $$ = new Node("FuncDef", @$.first_line, 5, $1, $2, $3, $4, $5); }
       ;



//12.???????????????
FuncFParams: FuncFParam FuncFParams2                { $$ = new Node("FuncFParams", @$.first_line, 2, $1, $2); }
           ;
FuncFParams2: COMMA FuncFParam FuncFParams2         { $$ = new Node("FuncFParams2", @$.first_line, 3, $1, $2, $3); }
			|                                       { $$ = new Node("FuncFParams2", @$.first_line, 0); }
            ;

//13.????????????
FuncFParam: BType IDENT LB RB FuncFParam2           { $$ = new Node("FuncFParam", @$.first_line, 5, $1, $2, $3, $4, $5); }
		 | BType IDENT                              { $$ = new Node("FuncFParam", @$.first_line, 2, $1, $2); }
         ;
FuncFParam2: LB Exp RB FuncFParam2                  { $$ = new Node("FuncFParam2", @$.first_line, 4, $1, $2, $3, $4); }
		  |                                         { $$ = new Node("FuncFParam2", @$.first_line, 0); }
          ;
	
//14.?????????
Block: LC Block2 RC                                 { $$ = new Node("Block", @$.first_line, 3, $1, $2, $3); }
     ;
Block2: BlockItem Block2                            { $$ = new Node("Block2", @$.first_line, 2, $1, $2); }
	  |                                             { $$ = new Node("Block2", @$.first_line, 0); }
      ;

//15.????????????
BlockItem: Decl                                     { $$ = new Node("BlockItem", @$.first_line, 1, $1); }
		 | Stmt                                     { $$ = new Node("BlockItem", @$.first_line, 1, $1); }
         ;                          

//16.??????
Stmt: LVal ASSIGNOP Exp SEMI                        { $$ = new Node("Stmt", @$.first_line, 4, $1, $2, $3, $4); }
	| Exp SEMI                                      { $$ = new Node("Stmt", @$.first_line, 2, $1, $2); }
	| SEMI                                          { $$ = new Node("Stmt", @$.first_line, 1, $1); }
	| Block                                         { $$ = new Node("Stmt", @$.first_line, 1, $1); }
	| IF LP Cond RP Stmt ELSE Stmt                  { $$ = new Node("Stmt", @$.first_line, 7, $1, $2, $3, $4, $5, $6, $7); }
	| IF LP Cond RP Stmt %prec LOWER_THAN_ELSE      { $$ = new Node("Stmt", @$.first_line, 5, $1, $2, $3, $4, $5); }
	| WHILE LP Cond RP Stmt                         { $$ = new Node("Stmt", @$.first_line, 5, $1, $2, $3, $4, $5); }
	| BREAK SEMI                                    { $$ = new Node("Stmt", @$.first_line, 2, $1, $2); }
	| CONTINUE SEMI                                 { $$ = new Node("Stmt", @$.first_line, 2, $1, $2); }
	| RETURN Exp SEMI                               { $$ = new Node("Stmt", @$.first_line, 3, $1, $2, $3); }
	| RETURN SEMI                                   { $$ = new Node("Stmt", @$.first_line, 2, $1, $2); }
    ;

//************************************????????????????????????************************************

//17.????????????SysY ???????????? int/float ???????????????
Exp: AddExp                                         { $$ = new Node("Exp", @$.first_line, 1, $1); }
   ;

//18.???????????????
Cond: LOrExp                                        { $$ = new Node("Cond", @$.first_line, 1, $1); }
    ;

//19.???????????????
LVal: IDENT LVal2                                   { $$ = new Node("LVal", @$.first_line, 2, $1, $2); }
    ;
LVal2: LB Exp RB LVal2                              { $$ = new Node("LVal2", @$.first_line, 4, $1, $2, $3, $4); }
	 |                                              { $$ = new Node("LVal2", @$.first_line, 0); }
     ;

//20.???????????????
PrimaryExp: LP Exp RP                               { $$ = new Node("PrimaryExp", @$.first_line, 3, $1, $2, $3); }
    	  | LVal                                    { $$ = new Node("PrimaryExp", @$.first_line, 1, $1); }
		  | Number                                  { $$ = new Node("PrimaryExp", @$.first_line, 1, $1); }
          ;

//21.??????
Number: INTCONST	                                { $$ = new Node("Number", @$.first_line, 1, $1); }
      | FLOATCONST                                  { $$ = new Node("Number", @$.first_line, 1, $1); }
      ;

//22.???????????????
UnaryExp: PrimaryExp                                { $$ = new Node("UnaryExp", @$.first_line, 1, $1); }
		| IDENT LP FuncRParams RP                   { $$ = new Node("UnaryExp", @$.first_line, 4, $1, $2, $3, $4); }
		| IDENT LP RP                               { $$ = new Node("UnaryExp", @$.first_line, 3, $1, $2, $3); }
		| UnaryOp UnaryExp                          { $$ = new Node("UnaryExp", @$.first_line, 2, $1, $2); }
        ;
		
//23.???????????????
UnaryOp: PLUS                                       { $$ = new Node("UnaryOp", @$.first_line, 1, $1); }
	   | MINUS                                      { $$ = new Node("UnaryOp", @$.first_line, 1, $1); }
	   | NOT                                        { $$ = new Node("UnaryOp", @$.first_line, 1, $1); } 
       ;

//24.???????????????
FuncRParams: Exp FuncRParams2                       { $$ = new Node("FuncRParams", @$.first_line, 2, $1, $2); }
           ;
FuncRParams2: COMMA Exp FuncRParams2                { $$ = new Node("FuncRParams2", @$.first_line, 3, $1, $2, $3); }
		    |                                       { $$ = new Node("FuncRParams2", @$.first_line, 0); }
            ;

//25.??????????????????
MulExp: UnaryExp                                    { $$ = new Node("MulExp", @$.first_line, 1, $1); }
	  | MulExp MUL UnaryExp                         { $$ = new Node("MulExp", @$.first_line, 3, $1, $2, $3); }
	  | MulExp DIV UnaryExp                         { $$ = new Node("MulExp", @$.first_line, 3, $1, $2, $3); }
	  | MulExp MOD UnaryExp                         { $$ = new Node("MulExp", @$.first_line, 3, $1, $2, $3); }
      ;

//26.???????????????
AddExp: MulExp                                      { $$ = new Node("AddExp", @$.first_line, 1, $1); }
	  | AddExp PLUS MulExp                          { $$ = new Node("AddExp", @$.first_line, 3, $1, $2, $3); }
	  | AddExp MINUS MulExp                         { $$ = new Node("AddExp", @$.first_line, 3, $1, $2, $3); }
      ;

//27.???????????????
RelExp: AddExp                                      { $$ = new Node("RelExp", @$.first_line, 1, $1); }
	  | RelExp LT AddExp                            { $$ = new Node("RelExp", @$.first_line, 3, $1, $2, $3); }
	  | RelExp GT AddExp                            { $$ = new Node("RelExp", @$.first_line, 3, $1, $2, $3); }
	  | RelExp LE AddExp                            { $$ = new Node("RelExp", @$.first_line, 3, $1, $2, $3); }
	  | RelExp GE AddExp                            { $$ = new Node("RelExp", @$.first_line, 3, $1, $2, $3); }
      ;
		
//28.??????????????????
EqExp: RelExp                                       { $$ = new Node("EqExp", @$.first_line, 1, $1); }
	 | EqExp EQ RelExp                              { $$ = new Node("EqExp", @$.first_line, 3, $1, $2, $3); }
	 | EqExp NE RelExp                              { $$ = new Node("EqExp", @$.first_line, 3, $1, $2, $3); }
     ;

//29.??????????????????
LAndExp: EqExp                                      { $$ = new Node("LAndExp", @$.first_line, 1, $1); }
	   | LAndExp AND EqExp                          { $$ = new Node("LAndExp", @$.first_line, 3, $1, $2, $3); }
       ;

//30.??????????????????
LOrExp: LAndExp                                     { $$ = new Node("LOrExp", @$.first_line, 1, $1); }
	  | LOrExp OR LAndExp                           { $$ = new Node("LOrExp", @$.first_line, 3, $1, $2, $3); }
      ;

//31.???????????????
ConstExp: AddExp                                    { $$ = new Node("ConstExp", @$.first_line, 1, $1); }
        ;






%%


void 
MC::MC_Parser::error( const location_type &l, const std::string &err_message )
{
   std::cerr << "Error: " << err_message << " at " << l << "\n";
}