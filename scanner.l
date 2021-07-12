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
label|LABEL             {return LABEL;}
hash|HASH               {return HASH;}
loop|LOOP               {return LOOP;}
merge|MERGE             {return MERGE;}
force|FORCE             {return FORCE;}
disable|DISABLE         {return DISABLE;}
externalpushdown|EXTERNALPUSHDOWN       {return EXTERNALPUSHDOWN;}
concat|CONCAT           {return CONCAT;}
ignore_nonclustered_columnstore_index|IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX   {return IGNORE_NONCLUSTERED_COLUMNSTORE_INDEX;}
keep|KEEP               {return KEEP;}
keepfixed|KEEPFIXED     {return KEEPFIXED;}
plan|PLAN               {return PLAN;}
max_grant_percent|MAX_GRANT_PERCENT     {return MAX_GRANT_PERCENT;}
min_grant_percent|MIN_GRANT_PERCENT     {return MIN_GRANT_PERCENT;}
maxdop|MAXDOP           {return MAXDOP;}
maxrecursion|MAXRECURSION               {return MAXRECURSION;}
no_performance_spool|NO_PERFORMANCE_SPOOL   {return NO_PERFORMANCE_SPOOL;}
optimize|OPTIMIZE       {return OPTIMIZE;}
for|FOR                 {return FOR ;}
unknown|UNKNOWN         {return UNKNOWN;}
parameterization|PARAMETERIZATION       {return PARAMETERIZATION ;}
simple|SIMPLE           {return SIMPLE;}
forced|FORCED           {return FORCED;}
querytraceon|QUERYTRACEON               {return QUERYTRACEON;}
recompile|RECOMPILE     {return RECOMPILE;}
robust|ROBUST           {return ROBUST;}
scaleoutexecution|SCALEOUTEXECUTION     {return SCALEOUTEXECUTION;}
expand|EXPAND           {return EXPAND;}
views|VIEWS             {return VIEWS;}
fast|FAST               {return FAST;}
option|OPTION           {return OPTION;}
insert|INSERT           {return INSERT;}
delete|DELEDTE          {return DELETE;}
values|VALUES           {return VALUES;}
default|DEFAULT         {return DEFAULT;}
update|UPDATE           {return UPDATE;}
set|SET                 {return SET;}
current|CURRENT         {return CURRENT;}
of|OF                   {return OF;}
global|GLOBAL           {return GLOBAL;}
exists|EXISTS           {return EXISTS;}
filestream|FILESTREAM   {return FILESTREAM;}
collate|COLLATE         {return COLLATE;}
sparse|SPARSE           {return SPARSE;}
replication|REPLICATION {return REPLICATION;}
rowguidcol|ROWGUIDCOL   {return ROWGUIDCOL;}
constraint|CONSTRAINT   {return CONSTRAINT;}
primary|PRIMARY         {return PRIMARY;}
unique|UNIQUE           {return UNIQUE;}
key|KEY                 {return KEY;}
clustered|CLUSTERED     {return CLUSTERED;}
nonclustered|NONCLUSTERED               {return NONCLUSTERED;}
foreign|FOREIGN         {return FOREIGN;}
references|REFERENCES   {return REFERENCES;}
no|NO                   {return NO;}
action|ACTION           {return ACTION;}
cascade|CASCADE         {return CASCADE;}
check|CHECK             {return CHECK;}
index|INDEX             {return INDEX;}
create|CREATE           {return CREATE;}
table|TABLE             {return TABLE;}
alter|ALTER             {return ALTER;}
column|COLUMN           {return COLUMN;}
add|ADD                 {return ADD;}
drop|DROP               {return DROP;}
masked|MASKED           {return MASKED;}
persisted|PERSISTED     {return PERSISTED;}
hidden|HIDDEN           {return HIDDEN;}
funciton|FUNCTION       {return FUNCTION;}
off|OFF                 {return OFF;}
online|ONLINE           {return ONLINE;}
nocheck|NOCHECK         {return NOCHECK;}
period|PERIOD           {return PERIOD;}
system_time|SYSTEM_TIME {return SYSTEM_TIME;}
if|IF                   {return IF;}
trigger|TRIGGER         {return TRIGGER;}
change_tracking|CHANGE_TRACKING         {return CHANGE_TRACKING;}
enable|ENABLE           {return ENABLE;}
track_columns_updated|TRACK_COLUMNS_UPDATED {return TRACK_COLUMNS_UPDATED;}
move|MOVE               {return MOVE;}
to|TO                   {return TO;}
any|ANY                 {return ANY;}
some|SOME               {return SOME;}
truncate|TRUNCATE       {return TRUNCATE;}
partitions|PARTITIONS   {return PARTITIONS;}

    /* interger numbers */
-?[0-9]+                {
                            yylval.intVal = atoi(yytext);
                            return INTNUMBER;
                        }

    /* approximate number */
-?[0-9]+\.[0-9]* |
-?\.[0-9]+ |
-?[0-9]+E[-+]?[0-9]+ |
-?[0-9]+\.[0-9]*E[-+]?[0-9]+ |
-?\.[0-9]+E[-+]?[0-9]+   {
                            yylval.floatVal = atof(yytext);
                            return APPROXNUM;
                        }
    /*name */
[A-Za-z][A-Za-z0-9_]*   {
                            yylval.strVal = strdup(yytext);
                            return NAME;   
                        }
	/* strings */
'(\\.|''|[^'\n])*'      |
\"(\\.|\"\"|[^"\n])*\"  { yylval.strVal = strdup(yytext); return STRING; }

'(\\.|[^'\n])*$         { yyerror("Unterminated string"); }
\"(\\.|[^"\n])*$        { yyerror("Unterminated string"); }    

	/* user variables */
    /*@[0-9a-z_.$]+           |
@\"[^"\n]+\"            |
@`[^`\n]+`              |
@'[^'\n]+'              { yylval.strVal = strdup(yytext+1); return USERVAR; }

@\"[^"\n]*$             |
@`[^`\n]*$              |
@'[^'\n]*$              { yyerror("unterminated quoted user variable %s", yytext); }*/

    /* operators */
[;,()-+*/\n.]           {return *yytext;}

    /* comparison operator */
"="                     {yylval.subtok = 4; return EQUAL;}
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