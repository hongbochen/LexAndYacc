%{
/*
 * 这个例子演示了简单的识别
 * 动词/非动词
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

[a-zA-Z]+	{ printf("%s: is not a verb\n", yytext); }

.|\n	{ ECHO; /* 通常的默认状态  */ }
%%

main()
{
	yylex();
}

int yywrap()
{
	return 1;
}
