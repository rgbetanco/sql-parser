%{
    #include "y.tab.h"

    int yywrap();
%}

%%
    /* reserved word */
select|SELECT           {return SELECT;}
from|FROM               {return FROM;}
all|ALL                 {return ALL;}
distinct|DISTINCT       {return DISTINCT;}
top|TOP                 {return TOP;}
percent|PERCENT         {return PERCENT;}

    /* interger numbers */
-?[0-9]+                {
                            yylval.intVal = atoi(yytext);
                            return INTNUMBER;
                        }

    /* approximate number */
    /*-?[0-9]+.[0-9]* |
-?.[0-9]+ |
-?[0-9]+E[-+]?[0-9]+ |
-?[0-9]+.[0-9]*E[-+]?[0-9]+ |
-?.[0-9]+E[-+]?[0-9]+   {
                            yylval.floatVal = atof(yytext);
                            return APPROXNUM;
                        }*/

[A-Za-z][A-Za-z0-9_]*   {
                            yylval.strVal = strdup(yytext);
                            return NAME;   
                        }     

    /* operators */
[;,()-+*/]               {return *yytext;}

    /* everything else */
[ \t\n]                  ;
.                        {yyerror("mystery character '%c'", *yytext);}
 
%%

int yywrap()
{
    return 1;
}