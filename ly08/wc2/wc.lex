%{
unsigned int charCount = 0,wordCount = 0,lineCount = 0;
%}

word    [^ \t\n]+
eol     \n

%%
{word}  { wordCount++; charCount+=yyleng; }
{eol}   { charCount++; lineCount++; }
.       { charCount++; }

%%
int main(argc,argv)
int argc;
char **argv;
{
    if(argc > 1){
        FILE *file;
        file = fopen(argv[1],"r");
        if(!file){
            fprintf(stderr,"could not open %s\n",argv[1]);
            exit(1);
        }

        yyin = file;
    }

    yylex();
    printf("%d %d %d\n",lineCount,wordCount,charCount);
    return 0;
}

int yywrap()
{
    // 0 - 输入未完成 1 - 输入已完成
    return 1;
}
