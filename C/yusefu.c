#include<stdio.h>
#include<stdlib.h>

struct node
{
	int num;	
	struct node *next;
};


void printlist(struct node *head)
{
	struct node *p=head->next;
	for(;p!=NULL;p=p->next)		
		printf("%d ",p->num);
}


struct node *init_circle(struct node *head)
{
	struct node *p,*q;
	int num;
	head=(struct node *)malloc(sizeof(struct node));
	head->next=NULL;	
	while(scanf("%d",&num)!=EOF)
	{
		p=(struct node *)malloc(sizeof(struct node));
		p->num=num;
		if(head->next==NULL)
			q=p;
		p->next=head->next;
		head->next=p;
	}
	q->next=p;
	return p;
}

void yuesefu(struct node *head,int select)
{
	int count=1;
	struct node *p=head,*q=NULL;

	while(p->next!=p)
	{
		
		count++;
		q=p;
		p=p->next;
		if(count==select)
		{
			printf("%d ",p->num);
			q->next=p->next;
			count=0;
		}
	}
}


int main(void)
{
	struct node *head=NULL;
	head=init_circle(head);
	int select;
	scanf("%d",&select);
	yuesefu(head,select);	
	//printlist(head);
	return 0;
}
