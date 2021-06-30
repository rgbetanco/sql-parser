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
as|AS                   {return AS;}
with|WITH               {return WITH;}
ties|TIES               {return TIES;}
into|INTO               {return INTO;}
where|WHERE             {return WHERE;}

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
    /*name */
[A-Za-z][A-Za-z0-9_]*   {
                            yylval.strVal = strdup(yytext);
                            return NAME;   
                        }

    /* operators */
[;,()-+*/\n=.]            {return *yytext;}

    /* subtok */
"="     {yylval.subtok = 4; return COMPARISON;}
"<=>"   {yylval.subtok = 12; return COMPARISON;}
">="    {yylval.subtok = 6; return COMPARISON;}
">"     {yylval.subtok = 2; return COMPARISON;}
"<="    {yylval.subtok = 5; return COMPARISON;}
"<"     {yylval.subtok = 1; return COMPARISON;}
"!="    |
"<>"    {yylval.subtok = 3; return COMPARISON;}

    /* everything else */
[ \t]                   ;
.                       {yyerror("mystery character '%c'", *yytext);}

%%

int yywrap()
{
    return 1;
}