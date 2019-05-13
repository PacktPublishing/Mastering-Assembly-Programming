
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main()
{
	/*
		This buffer is used for IO interactions with
		a user.
	*/
	char	ioBuffer[128];

	/*
		This would be a dynamically allocated buffer
		for internal storage of user's input.
	*/
	char*	stringBuffer;

	/* Prompt for user input. */
	printf("Enter your name: ");

	/* This is the core of the problem */
	gets(ioBuffer);

	/* 
		Copy user's input into dynamically allocated
		buffer.
	*/
	stringBuffer = (char*)malloc(strlen(ioBuffer) + 1);
	strcpy(stringBuffer, ioBuffer);

	/*
		Show user's input and free local buffer.
	*/
	printf("\n\nYour name is: %s", stringBuffer);
	free(stringBuffer);
	return 0;
}