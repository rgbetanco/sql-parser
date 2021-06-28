%{
    #include "y.tab.h"

    int yywrap();
%}

%%

select|SELECT           {return SELECT;}
from|FROM               {return FROM;}

[A-Za-z][A-Za-z0-9_]*   {
                            yylval.strVal = strdup(yytext);
                            return NAME;   
                        }

[;\n,]                   {return *yytext;}

.                       ;
 
%%

int yywrap()
{
    return 1;
}