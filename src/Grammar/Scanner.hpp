#ifndef _SYSYSCANNER_HPP_
#define _SYSYSCANNER_HPP_

#if ! defined(yyFlexLexerOnce)
#include <FlexLexer.h>
#endif

#include "parser.tab.hh"
#include "location.hh"

namespace grammar{

class Scanner : public yyFlexLexer{
public:
   
   Scanner(std::istream *in) : yyFlexLexer(in) {};
   virtual ~Scanner() {};

   //get rid of override virtual function warning
   using FlexLexer::yylex;

   virtual
   int yylex( grammar::Parser::semantic_type * const lval, 
              grammar::Parser::location_type *location );

private:
   /* yyval ptr */
   Parser::semantic_type *yylval = nullptr;
};

}


#endif /* END __MCSCANNER_HPP__ */