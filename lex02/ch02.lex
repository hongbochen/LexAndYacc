%{
/*
 * 扩展第一个示例以识别其他的词性
 */
%}
%%

[\t ]+	/* 忽略空白 */ ;

is |
am |
are |
were |
was |
be |
being |
been |
do |
does |
did |
will |
would |
should |
can |
could |
has |
have |
had |
go	{ printf("%s: is a verb\n",yytext); }

very |
simply |
gently |
quietly |
calmly |
angrily	{ printf("%s: is an anverb\n",yytext); }

to |
from |
behind |
above |
below |
between	{ printf("%s: is a preposition\n",yytext); }

if |
then |
and |
but |
or	{ printf("%s: is a conjunction\n",yytext); }

their |
my |
your |
his |
her |
its	{ printf("%s: is an adjective\n",yytext); }

I |
you |
he |
she |
we |
they	{ printf("%s: is a pronoun\n",yytext); }

[a-zA-Z]+	{
	printf("%s: don't recognize,might be a noun\n",yytext);
	}

.|\n	{ ECHO; /* 通常的默认状态 */ }
%%

main()
{
	yylex();
}

int yywrap()
{
	return 1;
}
