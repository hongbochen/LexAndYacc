%{
    #include <stdio.h>
    /* We found the following required for some yacc implementations */
    /* #define YYSTYPE int */
%}

%token NOUN PRONOUN VERB ADVERB ADJECTIVE PREPOSITION CONJUNCTION

%%

sentence: simple_sentence { printf("Parsed a simple sentence.\n"); }
    | compound_sentence { printf("Parsed a compound sentence.\n"); }
    ;

simple_sentence: subject verb object
    | subject verb object pre_phrase
    ;

compound_sentence: simple_sentence CONJUNCTION simple_sentence
    | compound_sentence CONJUNCTION simple_sentence
    ;

subject: NOUN
    | PRONOUN
    | ADJECTIVE subject
    ;

verb: VERB
    | ADVERB VERB
    | verb VERB
    ;

object: NOUN
    | ADJECTIVE object
    ;

pre_phrase: PREPOSITION NOUN
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
