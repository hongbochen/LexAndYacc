**语法**

对于某些应用，我们所完成的简单的词类识别也许足够用了;而另一些应用需要识别特殊的标记序列并执行适当的动作。传统上，对这样的一套动作描述成为语法。

使用右箭头"->"意味着可以用一个新的符号取代一套特殊的标记。
例如：

subject ->noun\pronoun  指示一个新的符号subject是名词或代词。

**词法分析程序和语法分析程序的通信**

当一起使用lex扫描程序和yacc语法分析程序的时候，语法分析程序是比较高级别的例程。当他需要来自输入的标记时，就调用词法分析程序yylex()。然后，词法分析程序从头到尾扫描输入识别标记。他一找到对u语法分析程序有意义的标记就返回到语法分析程序，将返回标记的代码作为yylex()的值。

词法分析程序和语法分析程序必须对标记代码的内容达成一致。通过让yacc定义标记代码来解决这个问题。在我们的语法中，标记的词性是:NOUN,PRONOUN,VERB,ADVERB,ADJECTIVE,PREPOSITION和CONJUNCTION。yacc使用预处理程序#define将他们每一个都定义为小的整数。下面是一个示例：

```

#define NOUN 257
#define PRONOUN 258
#define VERB 258
#define ADVERB 260
#define ADJECTIVE 261
#define PREPOSITION 262
#define CONJUNCTION  263

```
输入的逻辑结束总是返回标记代码零。
下面这一段程序展示了新的词法分析程序的声明和规则段

名称为:forth.lex

```
%{

/*
* 我们现在构建一个由高级语法分析程序使用的词法分析程序
*/

#include "y.tab.h"  /* 来自语法分析程序的标记代码 */
#define LOOKUP 0 /* 默认情况 - 不是一个定义的单词类型 */

int state;

%}

%%

\n { state = LOOKUP; }
 
\.\n { state = LOOKUP;
	return 0; /* 句子结尾 */ 
}

^verb { state = VERB; }
^adj  { state = ADJECTIVE;  }
^adv  { state = ADVERB;  }
^noun { state = NOUN; }
^prep { state = PREPOSITION;}
^pron { state = PRONOUN; }
^conj { state = CONJUNCTION; }

[a-zA-Z]+ {
	if(state != LOOKUP){
			add_word(state,yytext);
	}else{

		switch(lookup_word(yytext)){
			case VERB:
				return(VERB);
			case ADJECTIVE:
				return(ADJECTIVE);
			case ADVERB:
				return(ADVERB);
			case NOUN:
				return(NOUN);
			case PRONOUN:
				return(PRONOUN);
			case CONJUNCTION:
				return(CONJUNCTION);
			default:
				printf("%s: do not recognize!\n",yytext); /* 不返回 忽略 */
		}
	}
}

. ;

%%

/* 定义一个单词和类型的链表 */
struct word{
	char *word_name;
	int word_type;
	struct word *next;
};

struct word *word_list; /* 单词链表中的第一个元素 */
extern void *malloc();


int add_word(int type,char *word)
{
	struct word *wp;
	if(lookup_word(word) != LOOKUP){
		printf("!! warning: word %s already defined\n",word);
		return 0;
	}

	/* 单词不在那里，分配一个新的条目并将它链接到链表上 */
	wp = (struct word *)malloc(sizeof(struct word));
	wp->next = word_list;

	/* 还必须复制单词本身 */
	wp->word_name = (char *)malloc(strlen(word)+1);
	strcpy(wp->word_name,word);
	wp->word_type = type;
	word_list = wp;

	return 1;  /* 添加成功 */
}

int lookup_word(char *word)
{
	struct word *wp = word_list;

	/* 向下搜索列表以寻找单词 */
	for(;wp;wp = wp->next){
		if(strcmp(wp->word_name,word) == 0)
			return wp->word_type;
	}

	return LOOKUP;
}

int yywrap()
{
	return 1;
}

```

他和之前的词法分析程序有一下几个区别：
1：词法分析程序中使用的词性名字改变为与词法分析程序中的标记名字相一致
2：添加return语句将所识别的单词的标记代码传递给语法分析程序
3：词法分析程序中定义新单词的标记没有任何return语句，因为语法分析程序不“关心”它们。

其中，返回语句表明yylex()操作类似与协同程序。每次语法分析程序调用他时，
都在他停止的那一点进行处理。这样就允许我们渐进地检查和操作输入流。

同时还增加了一条规则来标记句子的结尾：

```
\.\n { state = LOOKUP;
          return 0; /* 句子结尾 */
}
```

句号前面的反斜杠引用这个句号，所以这条规则与后跟一个换行的句号匹配。对词法分析程序所做的另一个改变是省略
目前语法分析程序中提供的main()例程。

**yacc语法分析程序**

下面程序介绍了yacc语法中的第一步。
forth.y

```
%{
/*
 * 用于识别英文句子基本语法的词法分析程序
 */
#include <stdio.h>
	
%}

%token NOUN PRONOUN VERB ADVERB ADJECTIVE PREPOSITION CONJUNCTION 

%%

sentence: subject VERB object { printf("Sentence is valid.\n"); }
	;

subject:	NOUN
	|	PRONOUN
	;

object:	NOUN
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

```

yacc语法分析程序的结构类似与lex语法分析程序的结构。使用%{ %}括起的部分为定一段，使用%% %%括起的为规则段，%token 表示采用8个标记，通常规定标记名都用大写字母，而语法分析程序中的其他名字大部分或完全是小写字母.

最终要的子程序main()，重复调用yyparse()函数知道词法分析程序的输入文件结束，例程yyparse()是由yacc生成的语法分析程序，当词法分析程序看到行的结尾处的句号时返回零标记，表示当前分析的输入已经完成。

规则段将实际语法描述为一套产生式规则或简称为规则。每条规则由符号":"操作符左侧的一个名字，右侧的符号列表和动作代码以及指示规则结尾的分号组成。默认情况下，第一条规则是最高级别的规则。典型的简单的规则的右侧有一个符号。规则左侧的符号在其他规则中能像标记一样使用。

语法中使用特殊字符"|"，表示或;规则的动作部分由C块组成，以"{}"括起。因为sentence是最高层的符号，所以整个输入必须匹配sentence。当词法分析程序报告输入结束的时候，分析程序返回到他的调用程序。在该情况下就是主程序。随后对yyparse()的调用重置状态并再次开始处理。如果看到输入标记的"subject VERB object"列表，则示例打印一条消息，如果不匹配的话，则会调用yyerror()函数，识别特殊的规则error。可以提供错误恢复代码。尝试将分析程序返回到能够继续分析的状态。如果错误恢复失败，即没有错误恢复代码，yyparse()在发现错误后，返回调用程序。

下面是我们的Makefile程序:

```
all:
	lex forth.lex
	yacc -d forth.y
	gcc -c lex.yy.c y.tab.c
	gcc -o hello lex.yy.o y.tab.o -ll

clean:
	rm lex.yy.o y.tab.o lex.yy.c y.tab.c y.tab.h hello
	
```


下面我们使用命令:

```
make
```

对文件进行编译，编译完成之后，我们运行该程序：

```
./hello
```

程序的输出结果，我们来测试一下，运行之后，我们输入下面的语句:

```
verb are
noun you man
you are man 

```

下面是程序的输出结果：
![这里写图片描述](http://img.blog.csdn.net/20150517153125681)

下面一篇博客将会使用该代码进行扩展，扩展一个简单的小学英语语法分析程序。


