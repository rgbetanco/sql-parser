%{
    #include "y.tab.h"

    int yywrap();
%}

%%

select                  {return SELECT;}
from                    {return FROM;}

[A-Za-z][A-Za-z0-9_]*   {
                            yylval.strVal = strdup(yytext);
                            return NAME;   
                        }

[;\n]                   {return *yytext;}

.  ;
 
%%

int yywrap()
{
    return 1;
}