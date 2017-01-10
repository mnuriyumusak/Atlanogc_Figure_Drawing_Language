%{
#include<iostream>
#include "y.tab.h"
using namespace std;
int yyparse();
int commentNumber = 0;
%}
%option yylineno

ASSIGN =
DIGIT [0-9]
SPACE [ \t]+
STRING \".*\"
ALPHABETIC [a-zA-Z]
ALPHANUMERIC ({ALPHABETIC}|{DIGIT})
ID {ALPHABETIC}{ALPHANUMERIC}*
INTEGER [-]?{DIGIT}+
FLOAT [-]?{DIGIT}+\.{DIGIT}+
LPARAM \(
RPARAM \)
LBRACE \{
RBRACE \}
COMMA ,
NEWLINE \n
SEMICOLON ;
PLUS \+
MINUS \-
MUL \*
DIV \/
BOOLEAN true|false
AND &&
OR \|\|
NOT !
LT <
GT >
LTE <=
GTE >=
EQUAL ==
NOTEQUAL !=
VOID void
MAIN main
BOUNDINGBOX BoundingBox
LOCATION Location
SIZE Size
LINE Line
DRAW draw
RECTANGLE Rectangle
OVAL Oval
COLOR Color
DRAWOVAL drawOval
DRAWRECTANGLE drawRectangle
DRAWLINE drawLine
DRAWSTRING drawString
EXTENSION extension
FUNCTION func
RETURN return
FOR for
WHILE while
DO do
IF if
ELSE else
NONSTAR [^\*]
NONSTARNONDIV [^\*/]s
NONNEWLINE [^\n]
NEW new
%x IN_COMMENT 

%%
<INITIAL>"/*"           {BEGIN(IN_COMMENT); commentNumber++;}
<INITIAL>"//"           {BEGIN(IN_COMMENT);}
<IN_COMMENT>"*/"        {commentNumber--;if(commentNumber==0){BEGIN(INITIAL);} ; }
<IN_COMMENT>"/*"         {commentNumber++;}
<IN_COMMENT>"\n"        {if(commentNumber==0){BEGIN(INITIAL); ; }} 
<IN_COMMENT>.  

{NEWLINE} ;
{SPACE} ;
{NEW} return NEW;
{VOID} return VOID ;
{MAIN} return MAIN ;
{BOUNDINGBOX} return BOUNDINGBOX ;
{LOCATION} return LOCATION ;
{SIZE} return SIZE ;
{LINE} return LINE ;
{DRAW} return DRAW ;
{RECTANGLE} return RECTANGLE ;
{OVAL} return OVAL ;
{COLOR} return COLOR ;
{DRAWOVAL} return DRAWOVAL ; 
{DRAWRECTANGLE} return DRAWRECTANGLE ;
{DRAWSTRING} return DRAWSTRING ;
{DRAWLINE} return DRAWLINE ;
{EXTENSION} return EXTENSION ;
{SEMICOLON} return SEMICOLON ;
{FUNCTION} return FUNCTION ;
{IF} return IF ;
{ELSE} return ELSE ;
{RETURN} return RETURN ;
{FOR} return FOR ;
{WHILE} return WHILE ;
{DO} return DO ;
{COMMA} return COMMA ;
{ASSIGN} return ASSIGN ;
{AND} return AND ;
{OR} return OR ;
{EQUAL} return EQUAL ;
{NOTEQUAL} return NOTEQUAL ;
{NOT} return NOT ;
{LTE} return LTE ;
{GTE} return GTE ;
{LT} return LT ;
{GT} return GT ;
{LBRACE} return LBRACE ;
{RBRACE} return RBRACE ;
{PLUS} return PLUS ;
{MINUS} return MINUS ;
{MUL} return MUL ;
{DIV} return DIV ;
{LPARAM} return LPARAM ;
{RPARAM} return RPARAM ;
{STRING} return STRING ;
{BOOLEAN} return BOOLEAN ;
{INTEGER} return INTEGER ;
{FLOAT} return FLOAT ;
{ID} {yylval.string=strdup(yytext);return ID;};

%%
int yywrap()
{
	return 1;
}












