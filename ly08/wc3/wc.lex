%{
/*
 * 多文件的单词计数程序
 *
 */

 unsigned long charCount = 0,wordCount = 0,lineCount = 0;
 #undef yywrap   /* 默认情况下有时是一个宏 */

%}

word [^ \t\n]+
eol  \n

%%
{word} { wordCount++; charCount += yyleng; }
{eol}  { charCount++; lineCount++; }
.      charCount++;

%%

char **fileList;
unsigned currentFile = 0;
unsigned nFiles;
unsigned long totalCC = 0;
unsigned long totalWC = 0;
unsigned long totalLC = 0;

int main(int argc,char *argv[])
{
    FILE *file;

    fileList = argv + 1;
    nFiles = argc - 1;

    if(argc == 2){
        /*
         * 因为不需要打印摘要行，所以处理单个文件的情况
         * 与处理多个文件的情况不同
         *
         */
         currentFile = 1;
         file = fopen(argv[1],"r");
         if(!file){
            fprintf(stderr,"could not open %s\n",argv[1]);
            exit(1);
         }
         yyin = file;
    }

    if(argc > 2)
        yywrap(); /* 打开第一个文件 */

    yylex();
    /*
     * 处理零个或一个文件与处理多个文件的又一个不同之处
     */
    if(argc > 2){
        printf("%8lu %8lu %8lu %s\n",lineCount,wordCount,charCount,fileList[currentFile-1]);
        totalCC += charCount;
        totalWC += wordCount;
        totalLC += lineCount;
        printf("%8lu %8lu %8lu total\n",totalLC,totalWC,totalCC);
    }else{
        printf("%8lu %8lu %8lu\n",lineCount,wordCount,charCount);
    }

    return 0;
}

/*
 * 词法分析程序调用yywrap处理EOF。（比如，在本例中
 * 我们连接到一个新文件）
 */

int yywrap()
{
    FILE *file;
    
    if((currentFile != 0) && (nFiles > 1) && (currentFile < nFiles))
    {
        /*
         * 打印出前一个文件的统计信息
         */
         printf("%8lu %8lu %8lu %s\n",lineCount,wordCount,charCount,fileList[currentFile-1]);
         totalCC += charCount;
         totalWC += wordCount;
         totalLC += lineCount;
         charCount = wordCount = lineCount = 0;
         fclose(yyin); /* 处理完这个文件 */
    }

    while(fileList[currentFile] != (char *)0){
        file = fopen(fileList[currentFile++],"r");
        if(file != NULL){
            yyin = file;
            break;
        }

        fprintf(stderr,"could not open %s\n",fileList[currentFile-1]);
    }

    return (file ? 0 : 1); /* 0表示还有更多的输入 */
}
























