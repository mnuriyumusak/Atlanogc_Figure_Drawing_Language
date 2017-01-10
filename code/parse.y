// Define the tokens

%token ASSIGN  
%token DIGIT 
%token SPACE 
%token STRING  
%token ALPHABETIC  
%token ALPHANUMERIC  
%token ID  
%token INTEGER  
%token FLOAT  
%token LPARAM 
%token RPARAM  
%token LBRACE  
%token RBRACE  
%token COMMA  
%token NEWLINE  
%token SEMICOLON  
%token PLUS  
%token MINUS  
%token MUL  
%token DIV  
%token BOOLEAN
%token AND  
%token OR  
%token NOT  
%token LT  
%token GT  
%token LTE  
%token GTE  
%token EQUAL  
%token NOTEQUAL  
%token VOID  
%token MAIN   
%token BOUNDINGBOX  
%token LOCATION  
%token SIZE  
%token LINE  
%token DRAW  
%token RECTANGLE  
%token OVAL  
%token COLOR  
%token DRAWOVAL  
%token DRAWRECTANGLE  
%token DRAWLINE  
%token DRAWSTRING  
%token EXTENSION  
%token FUNCTION  
%token RETURN  
%token FOR  
%token WHILE  
%token DO  
%token IF  
%token ELSE  
%token NONSTAR  
%token NONSTARNONDIV  
%token NONNEWLINE  
%token NEW  

// Define the union that can hold different values for the tokens
// For error showing
%union 
{
  char * string;
  int integer;
}

// Define the token value types
%type <string> ID
%type <string> id_def

// define associativity of operations
%left PLUS MINUS // the order defines precedence, 
%left MUL DIV // so * and / has higher precedence than + and -

%{ 
  #include <iostream> 
  #include <string>
  #include <set>
  using namespace std;
  // forward declarations
  extern int yylineno;
  void yyerror(string);
  int yylex(void);
  int numoferr;
  set<string> var_symbols;
  set<string> defined_func_symbols;
  set<string> used_func_symbols;
  set<string> defined_extension_symbols;
  set<string> used_extension_symbols;
  set<int> used_extension_line_no;
  set<int> used_func_line_no;
  int currentLineNo = -1;
  bool endOfProgram = false;
%}


%%
program :
    main_func program_tail |
    error {if(currentLineNo != yylineno && !endOfProgram){yyerror("main function required");}currentLineNo = yylineno;}

main_func :
    VOID MAIN LPARAM INTEGER COMMA INTEGER COMMA INTEGER RPARAM LBRACE statement_list RBRACE {endOfProgram = true;}

program_tail :
    func program_tail|
    extension program_tail |
    
func:
    FUNCTION ID LPARAM param_list RPARAM LBRACE statement_list RBRACE {defined_func_symbols.insert(string($2));}

extension:
    EXTENSION ID LPARAM param_list RPARAM LBRACE statement_list RBRACE {defined_extension_symbols.insert(string($2));}

statement_list:
    statement statement_list |

statement:
    expr SEMICOLON |
    for_stmt |
    while_stmt |
    do_while_stmt |
    if_stmt |
    error
    
expr:
    func_call |
    built_in_func_call |
    assignment |
 

assignment:
    ID ASSIGN rhs {var_symbols.insert(string($1));} |
    ID ASSIGN builtin_def {var_symbols.insert(string($1));} |
    id_def PLUS PLUS |
    ID ASSIGN extension_call  {var_symbols.insert(string($1));}  |
    id_def MINUS MINUS

func_call:
    ID LPARAM arg_list RPARAM {used_func_symbols.insert(string($1)); used_func_line_no.insert(int(yylineno));}

extension_call:
    NEW ID LPARAM arg_list RPARAM {used_extension_symbols.insert(string($2)); used_extension_line_no.insert(int(yylineno));}

built_in_func_call:
    DRAW LPARAM id_def built_in_func_call_1 |
    DRAWOVAL LPARAM INTEGER COMMA INTEGER RPARAM |
    DRAWOVAL LPARAM loc_def COMMA siz_def built_in_func_call_2 |
    DRAWLINE  LPARAM loc_def COMMA loc_def built_in_func_call_4 |
    DRAWRECTANGLE LPARAM INTEGER COMMA INTEGER RPARAM |
    DRAWRECTANGLE LPARAM loc_def COMMA siz_def built_in_func_call_6 |
    DRAWSTRING LPARAM  string_def COMMA loc_def built_in_func_call_8 


built_in_func_call_1:
    RPARAM |
    COMMA id_def RPARAM 

built_in_func_call_2:
    RPARAM |
    COMMA int_def built_in_func_call_3  

built_in_func_call_3:
    RPARAM |
    COMMA  color_def COMMA bool_def RPARAM 

built_in_func_call_4:
    RPARAM  |
    COMMA int_def COMMA int_def built_in_func_call_5 

built_in_func_call_5:
    RPARAM  |
    COMMA  color_def RPARAM  

built_in_func_call_6:
    RPARAM |
    COMMA int_def COMMA bool_def built_in_func_call_7 

built_in_func_call_7:
    RPARAM |
    COMMA color_def COMMA bool_def RPARAM 

built_in_func_call_8:
    RPARAM |
    COMMA int_def built_in_func_call_9 

built_in_func_call_9:
    RPARAM |
    COMMA color_def RPARAM 


arg_list:
    arg arg_list_tail |
        

arg_list_tail:
    COMMA arg arg_list_tail |

arg:
    rhs | 
    arg_token

rhs:
    art_expr |
    conditional |
    string_add
    
string_add:
    STRING string_tail
    
string_tail:
    PLUS STRING |
    PLUS int_def |
    PLUS FLOAT |
    
art_expr:
    art_expr add term |
    term

term:
    term mul factor |
    factor

factor:
    operand |
    LPARAM art_expr RPARAM

add:
    PLUS |
    MINUS

mul:
    MUL |
    DIV

operand:
    INTEGER |
    float_def 
    
    
param_list:
    ID param_list_tail {var_symbols.insert(string($1));} |
    
param_list_tail:
    COMMA ID param_list_tail {var_symbols.insert(string($2));} |
    
arg_token:
    location_def |
    size_def |
    boundingbox_def |
    color_def |
    line_def |
    rectangle_def |
    oval_def 

    
builtin_def:
    arg_token 

    
string_def: 
    string_add | 
    id_def
    
int_def:
    INTEGER |
    id_def

bool_def:
    BOOLEAN |
    id_def

float_def:
    FLOAT |
    id_def
    
loc_def:
    location_def |
    id_def

location_def:
    LOCATION LPARAM int_def COMMA int_def RPARAM

siz_def: 
    size_def | 
    id_def
    
size_def:
    SIZE LPARAM int_def COMMA int_def RPARAM

clr_def: 
    color_def |
    id_def
    
color_def:
    COLOR LPARAM color_param RPARAM

color_param:
    int_def COMMA int_def COMMA int_def |
    string_def

    
line_def:
    LINE LPARAM line_param RPARAM

line_param:
    line_param_1 line_style_0 

line_param_1:
    location_def |
    string_def 

line_param_2:
    location_def |
    int_def 

line_param_3:
    int_def 

line_param_4:
     color_def  |
     int_def

line_param_5:
    clr_def 

line_style_0:
    COMMA line_param_2 line_style_1  |

line_style_1:
    COMMA line_param_3 line_style_2 |

line_style_2:
    COMMA line_param_4 line_style_3 |

line_style_3:
    COMMA line_param_5 |


boundingbox_def:
    BOUNDINGBOX LPARAM loc_def COMMA siz_def RPARAM

    
rectangle_def:
    RECTANGLE LPARAM rect_param RPARAM
    
rect_param:
     rect_param_1 COMMA rect_param_2 rect_style_1 |
    
rect_param_1:
    location_def |
    int_def

rect_param_2:
    size_def |
    bool_def

rect_param_3:
    color_def |
    int_def

rect_param_4:
    bool_def

rect_param_5:
    clr_def

rect_param_6:
    bool_def

rect_style_1:
    COMMA rect_param_3 COMMA rect_param_4 rect_style_2 |

rect_style_2:
    COMMA rect_param_5 COMMA rect_param_6 |


oval_def:
    OVAL LPARAM oval_param RPARAM
    
oval_param:
    oval_param_1 oval_style_1 |

oval_param_1:
    location_def |
    int_def

oval_param_2:
    color_def |
    siz_def

oval_param_3:
    bool_def |
    INTEGER
oval_param_4:
    clr_def
oval_param_5:
    bool_def

oval_style_1:
    COMMA oval_param_2 oval_style_2 |

oval_style_2:
    COMMA oval_param_3 oval_style_3 |

oval_style_3:
    COMMA oval_param_4 COMMA oval_param_5 |

id_def:
    ID {if(var_symbols.count(string($1))==0) yyerror("variable " + string($1) + " is not defined");}

conditional:
    BOOLEAN conditional_2 |
    art_expr bool_op conditional_1 |
    LPARAM conditional RPARAM 

conditional_1:
    BOOLEAN |
    art_expr 

conditional_2:
    bool_op conditional_3 |

conditional_3:
    conditional |
    art_expr 

bool_op:
    AND |
    OR |
    LT |
    GT |
    LTE |
    GTE |
    EQUAL |
    NOTEQUAL

loop_cond:
    conditional |
    error {yyerror("conditional expected");}

for_stmt:
    FOR LPARAM assignment SEMICOLON loop_cond SEMICOLON assignment RPARAM LBRACE statement_list RBRACE

while_stmt:
    WHILE LPARAM loop_cond RPARAM LBRACE statement_list RBRACE

do_while_stmt:
    DO LBRACE statement_list RBRACE WHILE LPARAM loop_cond RPARAM SEMICOLON

if_stmt:
    IF LPARAM loop_cond RPARAM LBRACE statement_list RBRACE else_stmt

else_stmt:
    ELSE LBRACE statement_list RBRACE |

%%

// report errors
extern int yylineno;

void yyerror(string s) 
{
	numoferr++;
	cout << "errorat line " << yylineno << ": " << s << endl;
}

void extensionCallCheck() 
{
    set<string>::iterator it;
    int count = 0;
    for (it = used_extension_symbols.begin(); it != used_extension_symbols.end(); ++it)
    {
         string tmp = *it;
         set<int>::iterator it3;
         int count2 = 0;
         int lineno = -1;
         for (it3 = used_extension_line_no.begin(); it3 != used_extension_line_no.end(); ++it3)
         {
            if(count == count2)
            {
                lineno = *it3;
                break;
            }
            count2++;
         }
         set<string>::iterator it2;
         bool stopFlag = false;
         for (it2 = defined_extension_symbols.begin(); it2 != defined_extension_symbols.end(); ++it2)
         {
            string tmp2 = *it2;
            if(tmp.compare(tmp2) == 0)
            {
                 stopFlag = true;
                break;
            }
         }
         if(!stopFlag)
         {
            cout << "error at line " << lineno << ": " << tmp << " is not defined"  << endl;
            numoferr++;
         }
        stopFlag = false;
         count++;
    }
}

void funcCallCheck() 
{
    set<string>::iterator it;
    int count = 0;
    for (it = used_func_symbols.begin(); it != used_func_symbols.end(); ++it)
    {
         string tmp = *it;
         set<int>::iterator it3;
         int count2 = 0;
         int lineno = -1;
         for (it3 = used_func_line_no.begin(); it3 != used_func_line_no.end(); ++it3)
         {
            if(count == count2)
            {
                lineno = *it3;
                break;
            }
            count2++;
         }
        set<string>::iterator it2;
         bool stopFlag = false;
         for (it2 = defined_func_symbols.begin(); it2 != defined_func_symbols.end(); ++it2)
         {
            string tmp2 = *it2;
            if(tmp.compare(tmp2) == 0)
            {
                stopFlag = true;
                break;
            }
         }
         if(!stopFlag)
         {
            cout << "error at line " << lineno << ": " << tmp << " is not defined"  << endl;
            numoferr++;
        }
        stopFlag = false;
         count++;
    }
}

int main()
{
	numoferr=0;
	yyparse();
    funcCallCheck();
    extensionCallCheck();
	if(numoferr>0) {
		cout << "Parsing completed with " << numoferr << " errors" <<endl;
	} else {
		cout << "Successfull" <<endl;
	}
	return 0;
}

