#include <stdio.h>
#include <ctype.h>

#define NUMBER 400
#define COMMENT 401
#define TEXT 402
#define COMMAND 403

int main(int argc,char **argv)
{
    int val;
    
    while(val = lexer())
        printf("value is %d.\n",val);

    return 0;
}

int lexer()
{
    int c;

    while((c = getchar()) == ' ' || c == '\t');

    if(c == EOF)
        return 0;
    if(c == '.' || isdigit(c)) /* 数字 */
    {
        while((c = getchar()) != EOF && isdigit(c));
        ungetc(c,stdin);

        return NUMBER;
    }

    if(c == '#') /* 注释 */
    {
        int index = 1;
        while((c = getchar()) != EOF && c != '\n');
        ungetc(c,stdin);

        return COMMENT;
    }
    if(c == '"') /* 字符串 */
    {
        int index = 1;
        while((c = getchar()) != EOF && c != '"' && c != '\n');

        if(c == '\n')
            ungetc(c,stdin);

        return TEXT;
    }
    if(isalpha(c)) /* 命令 */
    {
        int index = 1;
        while((c = getchar()) != EOF && isalnum(c));

        ungetc(c,stdin);

        return COMMAND;
    }
    return c;
}











