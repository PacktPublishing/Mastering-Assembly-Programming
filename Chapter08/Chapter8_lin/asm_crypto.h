#pragma once

#ifdef __cplusplus
#define EXTERN 
extern "C"
{
#else
#define EXTERN extern
#endif

#ifdef WIN32
#pragma pack(push, 1)
#define PACKED
#else
#define PACKED __attribute__((packed, aligned(1)))
#endif

typedef struct  
{
	void(*f_set_data_pointer)(void*);
	void(*f_set_data_length)(int);
	void(*f_encrypt)(void);
	void(*f_decrypt)(void);
}PACKED crypto_functions_t, *pcrypto_functions_t;

#ifdef WIN32
#pragma pack(pop)
#endif

EXTERN pcrypto_functions_t GetPointers(void);

#ifdef __cplusplus
}
#endif



