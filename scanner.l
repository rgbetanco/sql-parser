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
like|LIKE               {return LIKE;}
and|AND|&&|&            {return AND;}
or|OR|\|\||\|           {return OR;}
in|IN                   {return IN;}
between|BETWEEN         {return BETWEEN;}
group|GROUPO            {return GROUP;}
by|BY                   {return BY;}
rollup|ROLLUP           {return ROLLUP;}
grouping|GROUPING       {return GROUPING;}
sets|SETS               {return SETS;}
having|HAVING           {return HAVING;}
on|ON                   {return ON;}
join|JOIN               {return JOIN;}
inner|INNER             {return INNER;}
outer|OUTER             {return OUTER;}
right|RIGHT             {return RIGHT;}
left|LEFT               {return LEFT;}
full|FULL               {return FULL;}
reduce|REDUCE           {return REDUCE;}
replicate|REPLICATE     {return REPLICATE;}
redistribute|REDISTRIBUTE {return REDISTRIBUTE;}
cross|CROSS             {return CROSS;}
apply|APPLY             {return APPLY;}
order|ORDER             {return ORDER;}
asc|ASC                 {return ASC;}
desc|DESC               {return DESC;}
union|UNION             {return UNION;}
except|EXCEPT           {return EXCEPT;}
intersect|INTERSECT     {return INTERSECT;}
is|IS                   {return IS;}
not|NOT                 {return NOT;}
null|NULL               {return NULLX;}

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
	/* strings */
'(\\.|''|[^'\n])*'   |
\"(\\.|\"\"|[^"\n])*\"  { yylval.strVal = strdup(yytext); return STRING; }

'(\\.|[^'\n])*$         { yyerror("Unterminated string"); }
\"(\\.|[^"\n])*$        { yyerror("Unterminated string"); }             

    /* operators */
[;,()-+*/\n.]           {return *yytext;}

    /* comparison operator */
"="                     {yylval.subtok = 4; return COMPARISON;}
"<=>"                   {yylval.subtok = 12; return COMPARISON;}
">="                    {yylval.subtok = 6; return COMPARISON;}
">"                     {yylval.subtok = 2; return COMPARISON;}
"<="                    {yylval.subtok = 5; return COMPARISON;}
"<"                     {yylval.subtok = 1; return COMPARISON;}
"!="                    |
"<>"                    {yylval.subtok = 3; return COMPARISON;}

    /* everything else */
[ \t]                   ;
.                       {yyerror("mystery character '%c'", *yytext);}

%%

int yywrap()
{
    return 1;
}