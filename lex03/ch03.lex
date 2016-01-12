%{
	/*
 	 * 带符号表的单词识别程序
 	 */

	enum {
		LOOKUP = 0, /* 默认 - 查找而不是定义 */
		VERB,
		ADJ,
		ADV,
		NOUN,
		PREP,
		PRON,
		CONJ
	};

	int state;

	int add_word(int type,char *word);
	int lookup_word(char *word);
%}
%%

\n { state = LOOKUP; } /* 行结束，返回到默认状态 */

	/* 无论何时，行都以保留的词性名字开始 */
	/* 开始定义该类型的单词 */
^verb { state = VERB; }
^adj { state = ADJ; }
^adv { state = ADV; }
^noun { state = NOUN; }
^prep { state = PREP; }
^pron { state = PRON; }
^conj { state = CONJ; } 

[a-zA-Z]+ {
	/* 一个标准的单词，定义它或查找他 */
	if(state != LOOKUP){
		/* 定义当前的单词 */
		add_word(state,yytext);
	}else{
		switch(lookup_word(yytext)){
		case VERB: printf("%s: verb\n",yytext); break;
		case ADJ: printf("%s: adjective\n",yytext); break;
		case ADV: printf("%s: adverb\n",yytext); break;
		case NOUN: printf("%s: noun\n",yytext); break;
		case PREP: printf("%s: preposition\n",yytext); break;
		case PRON: printf("%s: pronoun\n",yytext); break;
		case CONJ: printf("%s:conjunction\n",yytext); break;
		default:
			printf("%s: don't recognize\n",yytext);
			break;
		}
	}
}

. /* 忽略其他东西 */
%%

int main()
{
	yylex();
	return 0;
}

int yywrap()
{
	return 1;
}

/* 定义一个单词和类型的链表 */
struct word
{
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
		printf("!!!warning: word %s already defined\n",word);
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

	return 1; /* 添加成功 */
}

int lookup_word(char *word)
{
	struct word *wp = word_list;

	/* 向下搜索以寻找单词 */
	for(;wp;wp = wp->next){
		if(strcmp(wp->word_name,word) == 0)
			return wp->word_type;
	}

	return LOOKUP; /* 没有找到 */ 
}
