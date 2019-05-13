#include "asm_crypto.h"
#include <stdio.h>

int main(void)
{
	char testString[] = {"Hello, from Linux!\n"};
	pcrypto_functions_t funcs;
	
	funcs = GetPointers();
	funcs->f_set_data_pointer(testString);
	funcs->f_set_data_length((int)sizeof testString);
	printf(testString);
	funcs->f_encrypt();
	funcs->f_decrypt();
	printf(testString);
	
	return 0;
}
