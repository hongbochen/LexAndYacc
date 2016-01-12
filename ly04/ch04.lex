%{
	/*
	 * 现在我们构建一个有高级语法分析程序使用的词法分析程序
	 */

	#include "y.tab.h"

	#define LOOKUP 0 /* 默认情况 - 不是一个定义的单词类型 */

	int state;	
%}

%%

\n { state = LOOKUP; }

\.\n { state = LOOKUP;
	return 0; /* 句子结尾 */ 
	}

^verb { state = VERB; }
^adj { state = ADJECTIVE; }
^adv { state = ADVERB; }
^noun { state = NOUN; }
^prep { state = PREPOSITION; }
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
		case PREPOSITION:
			return(PREPOSITION);
		case PRONOUN:
			return(PRONOUN);
		case CONJUNCTION:
			return(CONJUNCTION);
		default:
			printf("%s: don't recognize\n",yytext);
			/* 不反悔，忽略 */
		}
	}
}

. ;

%%

/* 定义一个单词和类型的链表 */
struct word
{
	char *word_name;
	int word_type;
	struct word *next;
};

struct word *word_list;  /* 单词链表中的第一个元素 */
extern void *malloc();

int add_word(int type,char *word)
{
	struct word *wp;
	if(lookup_word(word) != LOOKUP){
		printf("!!warning:word %s already defined\n",word);
		return 0;
	}

	/* 单词不在那里，分配一个新的条目并将他连接到链表上 */
	wp = (struct word *)malloc(sizeof(struct word));
	wp->next = word_list;

	/* 还必须复制单词本身 */
	wp->word_name = (char *)malloc(strlen(word)+1);
	strcpy(wp->word_name,word);
	wp->word_type = type;
	word_list = wp;

	return 1;  /* 成功添加 */
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










