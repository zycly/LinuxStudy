#include<stdio.h>
#include<stdlib.h>

struct node
{
	int num;
	struct node *next;
};

struct node *createlist(struct node *head)
{
	struct node *p,*q;
        int date;
	while(scanf("%d",&date)!=EOF)
	{
		p=(struct node *)malloc(sizeof(struct node));
		p->num=date;
		if(head==NULL)
			head=p;
		else
			q->next=p;
		q=p;
	}
	p->next=NULL;
	return head;
}

struct node *reverselist(struct node *head)
{
	struct node *pcur=head,*pre=NULL,*q;
	while(pcur!=NULL)
	{
		q=pcur->next;
		pcur->next=pre;
		pre=pcur;
		pcur=q;
	}
	return pre;
}

void printlist(struct node *head)
{
	struct node *p=head;
	for(;p;p=p->next)
		printf("%d ",p->num);
}


int main(void)
{
	struct node *head=NULL;
	head=createlist(head);
	printlist(head);
	printf("\n");
	head=reverselist(head);
	printlist(head);
	return 0;
}
