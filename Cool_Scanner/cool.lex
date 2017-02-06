/*
 *  The scanner definition for COOL.
 */

import java_cup.runtime.Symbol;

%%

%{

/*  Stuff enclosed in %{ %} is copied verbatim to the lexer class
 *  definition, all the extra variables/functions you want to use in the
 *  lexer actions should go here.  Don't remove or modify anything that
 *  was there initially.  */

    // Max size of string constants
    static int MAX_STR_CONST = 1025;

    // For assembling string constants
    StringBuffer string_buf = new StringBuffer();

    private int curr_lineno = 1;
    int get_curr_lineno() {
	return curr_lineno;
    }

    private AbstractSymbol filename;

    void set_filename(String fname) {
	filename = AbstractTable.stringtable.addString(fname);
    }

    AbstractSymbol curr_filename() {
	return filename;
    }
%}

CLASS = [cC][lL][aA][sS][sS]
ELSE = [eE][lL][sS][eE]
FALSE = [f][aA][lL][sS][eE]
FI =	[fF][iI]
IF =	[iI][fF]
IN =	[iI][nN]
INHERITS = [iI][nN][hH][eE][rR][iI][tT][sS]
ISVOID =	[iI][sS][vV][oO][iI][dD]
LET = [lL][eE][tT]
LOOP = [lL][oO][oO][pP]
POOL = [pP][oO][oO][lL]
THEN = [tT][hH][eE][nN]
WHILE =	[wW][hH][iI][lL][eE]
CASE = [cC][aA][sS][eE]
ESAC = [eE][sS][aA][cC]
NEW	= [nN][eE][wW]
OF = [oO][fF]
NOT	= [nN][oO][tT]
TRUE = [t][rR][uU][eE]
WHITESPACE = [ \t\n\f\v\r]
LETTER = [a-zA-Z]
DIGIT = [0-9]
%init{

/*  Stuff enclosed in %init{ %init} is copied verbatim to the lexer
 *  class constructor, all the extra initialization you want to do should
 *  go here.  Don't remove or modify anything that was there initially. */

    // empty for now
%init}

%eofval{

/*  Stuff enclosed in %eofval{ %eofval} specifies java code that is
 *  executed when end-of-file is reached.  If you use multiple lexical
 *  states and want to do something special if an EOF is encountered in
 *  one of those states, place your code in the switch statement.
 *  Ultimately, you should return the EOF symbol, or your lexer won't
 *  work.  */

    switch(yy_lexical_state) {
    case YYINITIAL:
	/* nothing special to do in the initial state */
	break;
	case COMMENT:
	yybegin(YYINITIAL);
	return new Symbol(TokenConstants.ERROR, new String("EOF in comment"));


	case COMMENTDASH:
	break;

	case STRING:
	yybegin(YYINITIAL);
    return new Symbol(TokenConstants.ERROR, new String("EOF in string constant"));
	


    }
    return new Symbol(TokenConstants.EOF);
%eofval}

%{
private int string_overflow=0;
private int string_underflow=0;
private int comment_count = 0;	
private boolean backslash = false;
%}
%class CoolLexer
%cup
%state STRING
%state COMMENT
%state COMMENTDASH
%%

<YYINITIAL>\n			{ /* Do nothing  if \n is encountered */
						curr_lineno+= 1;

						}
<YYINITIAL>{CLASS}		{ /* lexical rule for "CLASS" regular expression
						 described above.*/
						 return new Symbol(TokenConstants.CLASS); }

<YYINITIAL>{ELSE}		{ /* lexical rule for "ELSE" regular expression
						 described above.*/
						 return new Symbol(TokenConstants.ELSE); }

<YYINITIAL>{FALSE}		{ /* lexical rule for "FALSE" regular expression
						 described above*/
						 return new Symbol(TokenConstants.BOOL_CONST, new Boolean(false)); }  

<YYINITIAL>{IF}			{ /* lexical rule for "IF" regular expression 
						 described above */
		     		   	 return new Symbol(TokenConstants.IF); }						

<YYINITIAL>{FI}			{ /* lexical rule for "FI" regular expression
					     described above */ 
						 return new Symbol(TokenConstants.FI); }

<YYINITIAL>{IN}			{ /* lexical rule for "IN" regular expression
					     described above */
						 return new Symbol(TokenConstants.IN); } 						

<YYINITIAL>{INHERITS} 	{ /* lexical rule for "INHERITS" regular expression
					     described above */
						 return new Symbol(TokenConstants.INHERITS); }						 

<YYINITIAL>{ISVOID}		{ /* lexical rule for "ISVOID" regular expression 
					     described above */
						 return new Symbol(TokenConstants.ISVOID); }					 

<YYINITIAL>{LET}		{ /* lexical rule for "LET" regular expression
					     described above */
						 return new Symbol(TokenConstants.LET); }						 

<YYINITIAL>{LOOP}		{ /* lexical rule for "LOOP" regular expression 
						 described above */
						 return new Symbol(TokenConstants.LOOP); }	

<YYINITIAL>{POOL}		{ /* lexical rule for "POOL" regular expression
					     described above */
						 return new Symbol(TokenConstants.POOL); }						

<YYINITIAL>{THEN} 	 	{ /* lexical rule for "THEN" regular expression
						 decribed above*/
						 return new Symbol(TokenConstants.THEN); }

<YYINITIAL>{WHILE}		{ /* lexical rule for "WHILE" regular expression
					   	 described above */
						 return new Symbol(TokenConstants.WHILE); }

<YYINITIAL>{CASE}		{ /* lexiacl rule for "CASE" regular expression 
					     described above */
						 return new Symbol(TokenConstants.CASE); }

<YYINITIAL>{ESAC}		{ /* lexiacl rule for "ESAC" regular expression 
					     described above */
						 return new Symbol(TokenConstants.ESAC); }	

<YYINITIAL>{NEW}		{ /* lexiacl rule for "NEW" regular expression 
					     described above */
						 return new Symbol(TokenConstants.NEW); }	

<YYINITIAL>{OF}			{ /* lexiacl rule for "OF" regular expression 
					     described above */
						 return new Symbol(TokenConstants.OF); }	

<YYINITIAL>{NOT}		{ /* lexiacl rule for "NOT" regular expression 
					     described above */
						 return new Symbol(TokenConstants.NOT); }	

<YYINITIAL>{TRUE}		{ /* lexiacl rule for "TRUE" regular expression 
					     described above */
						 return new Symbol(TokenConstants.BOOL_CONST, new Boolean(true)); }	
					 
<YYINITIAL>{DIGIT}+		{ /* lexical rule for number as "DIGIT" followed by 
						  consecutive "DIGIT"'s or none*/
						return new Symbol(TokenConstants.INT_CONST, AbstractTable.inttable.addString(yytext())); }

<YYINITIAL>[A-Z](_|{DIGIT}|{LETTER})* { /* lexical rule for TYPE identifier starting from capital letter 
										followed by "DIGIT" or "LETTER" or '_' or none */
										return new Symbol(TokenConstants.TYPEID, AbstractTable.idtable.addString(yytext())); }

<YYINITIAL>[a-z](_|{DIGIT}|{LETTER})* { /* lexical rule for OBJECT identifier starting from small letter
										followed by "DIGIT" or "LETTER" or '_' or none */
										return new Symbol(TokenConstants.OBJECTID, AbstractTable.idtable.addString(yytext())); }


<YYINITIAL>{WHITESPACE}	{ /* Do nothing for "WHITESPACE" encountered in 
							 the input file*/}								
						

<YYINITIAL>"=>"			{ /* lexical rule for "=>" arrow */
                         return new Symbol(TokenConstants.DARROW); }

<YYINITIAL>"*)"			{ /* throws error on encountering end comment symbol*/
	                     return new Symbol(TokenConstants.ERROR, new String("Unmatched *)"));}

<YYINITIAL>"(*"			{ /* lexical rule on encountering start of
							 comment symbol; comment_count counts
							 the number of comments*/
							 yybegin(COMMENT);
							 comment_count = 1;
						}
<COMMENT>"(*"			{ /* lexical rule for nested comment*/
							 comment_count+= 1;
						}

<COMMENT>[^\n]			{ /* Do nothing for the text followed by "(*" */ }

<COMMENT>\n				{ /* Do nothing for the multiline comment*/
						 curr_lineno+= 1;
						}
		

<COMMENT>"*)"			{/* lexical rule on encountering closing of 
						    comment symbol; decrements the count of
						 	comment_count if value turns to 0 comment is closed  */
							comment_count-= 1;
							if(comment_count == 0){
									yybegin(YYINITIAL);
							}
							else{
									/* Do nothing if nested comment has still not exited*/ }
						}					 

<YYINITIAL>"*"			{ /* lexical rule for "*" i.e. multiplication operator */
                         return new Symbol(TokenConstants.MULT); }

<YYINITIAL>"("			{ /* lexical rule for "(" i.e. left paranthesis */
                         return new Symbol(TokenConstants.LPAREN); }

<YYINITIAL>";"			{ /* lexical rule for ";" i.e. semicolon */
                         return new Symbol(TokenConstants.SEMI); }

<YYINITIAL>":"			{ /* lexical rule for ":" i.e. colon */
						return new Symbol(TokenConstants.COLON);}

<YYINITIAL>"-"			{ /* lexical rule for "-" i.e. minus operator */
                         return new Symbol(TokenConstants.MINUS); }

<YYINITIAL>")"			{ /* lexical rule for ")" i.e. right paranethesis */
                         return new Symbol(TokenConstants.RPAREN); }

<YYINITIAL>"<"			{ /* lexical rule for "<" i.e. less than operator */
                         return new Symbol(TokenConstants.LT); }

<YYINITIAL>","			{ /* lexical rule for ","  i.e. comma */
                         return new Symbol(TokenConstants.COMMA); }

<YYINITIAL>"/"			{ /* lexical rule for "/" i.e. division operator */
                         return new Symbol(TokenConstants.DIV); }

<YYINITIAL>"+"			{ /* lexical rule for "+" i.e. plus operator */
                         return new Symbol(TokenConstants.PLUS); }

<YYINITIAL>"<-"			{ /* lexical rule for "<-" arrow.*/
                         return new Symbol(TokenConstants.ASSIGN); }

<YYINITIAL>"."			{ /* lexical rule for "." i.e. Dot*/
                         return new Symbol(TokenConstants.DOT); }

<YYINITIAL>"<="			{ /* lexical rule for "<=" i.e. less than equal to*/
                         return new Symbol(TokenConstants.LE); }

<YYINITIAL>"="			{ /* lexical rule for "=" i.e. equal */
                         return new Symbol(TokenConstants.EQ); }

<YYINITIAL>"~"			{ /* lexical rule for "~" i.e. negation */
                         return new Symbol(TokenConstants.NEG); }

<YYINITIAL>"{"			{ /* lexical rule for "{" i.e. left braces */
                         return new Symbol(TokenConstants.LBRACE); }

<YYINITIAL>"}"			{ /* lexical rule for "}" i.e. right braces */
                         return new Symbol(TokenConstants.RBRACE); }

<YYINITIAL>"@"			{ /* lexical rule for "@" i.e. At */
                         return new Symbol(TokenConstants.AT); }

<YYINITIAL>"--".* 		{ /*Nothing to do for "--" followed by anything*/ 
							yybegin(COMMENTDASH);}

<COMMENTDASH>\n			{ /* lexical rule on encountering "\n" terminates the comment
						  and returns to initial state */
							curr_lineno+=1;
     						yybegin(YYINITIAL);}



<YYINITIAL>\"			{ /* String starts*/
						
							string_buf.delete(0,string_buf.length());
							string_overflow=0;
							string_underflow=0;
							yybegin(STRING);

						}


<STRING>\"				{ /* String on encountering '"' ends */ 
							int length=string_buf.length();
							if((length > 0 && string_buf.charAt(string_buf.length()-1)=='\\') && !backslash) {
								string_buf.setCharAt(string_buf.length()-1,'\"');
							}
							else {
								yybegin(YYINITIAL); 
								if( string_overflow==1 || string_underflow==1 ) {
										if( string_overflow==1)
										return new Symbol(TokenConstants.ERROR, new String("String constant too long")); 
										if( string_underflow==1)
										return new Symbol(TokenConstants.ERROR, new String("String contains null character")); 

								}
							    return new Symbol(TokenConstants.STR_CONST, AbstractTable.stringtable.addString(string_buf.toString())); 
							}
						}

<STRING>\n				{ 
						  curr_lineno+=1; 
						  if(string_buf.length()== 0) {
						 	 yybegin(YYINITIAL);
						 //	 System.out.println("************** PAGAL**********"+yytext());

						 	 return new Symbol(TokenConstants.ERROR, new String("Unterminated string constant"));
						  }
						  else {
								  char c = string_buf.charAt(string_buf.length()-1);
								  if(c == '\\' && !backslash) {
										  string_buf.setCharAt(string_buf.length()-1, '\n');
							      }
								  else {
							  			  yybegin(YYINITIAL);
						 				// System.out.println("************** PAGAL**********"+yytext());

										  return new Symbol(TokenConstants.ERROR, new String("Unterminated string constant")); 
								  }
					     } 

						 }

<STRING>[^\n\"]	     	{
						if( string_underflow==0 || string_overflow==0){
							if(yytext().charAt(0) == '\0'){
								string_underflow=1;
							}
							else{
									
									int length = string_buf.length();
									if(length==0){
											//if nothing has yet been appended to 
											//string buffer, just append it.
											string_buf.append(yytext());
										//	System.out.println(yytext());
									}
									else if(length>MAX_STR_CONST){
											//length exceeding string limit
											string_overflow=1;
									
									}

									else{
											int previous = length-1;
											char prev_char = string_buf.charAt(previous);
											if(prev_char == '\\'  && !backslash ){
													if(yytext().charAt(0)=='b'){
													string_buf.setCharAt(previous, '\b');
													}
													else if(yytext().charAt(0)=='n'){
													string_buf.setCharAt(previous, '\n');
													}
													else if(yytext().charAt(0)=='t'){
													string_buf.setCharAt(previous, '\t');
													}
													else if(yytext().charAt(0)=='f'){
													string_buf.setCharAt(previous, '\f');
													}
													else if(yytext().charAt(0)=='\\'){
													string_buf.setCharAt(previous, '\\');
													backslash = true; /*append '\' symbol as it is in buffer
																	since first '\' indicates to take another 
																	'\' as it is.*/
													}
													else{
															string_buf.setCharAt(previous, yytext().charAt(0));
													}
													
											}
											else{
													backslash = false; //treat as a new backslash
													string_buf.append(yytext());
											}
				
											
									}

									
							}
							
						}

						}						

						
.		                { /* This rule should be the very last
   	                     in your lexical specification and
							 will match match everything not
							 matched by other lexical rules. */
					  		return new Symbol(TokenConstants.ERROR, new String( yytext())); 
						}
