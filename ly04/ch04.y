%{
	/*
	 * 用于识别英语句子基本语法的词法分析程序
	 */
	#include <stdio.h>
%}

%token NOUN PRONOUN VERB ADVERB ADJECTIVE PREPOSITION CONJUNCTION

%%

sentence: subject VERB object { printf("Sentence is valid.\n"); }
	;

subject: NOUN
	| PRONOUN
	;

object: NOUN
	;

%%

extern FILE *yyin;

int main()
{
	yyparse();
	while(!feof(yyin)){
		yyparse();
	}
	return 0;
}

yyerror(s)
char *s;
{
	fprintf(stderr,"%s\n",s);
}
