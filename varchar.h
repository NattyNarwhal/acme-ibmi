#include <stdint.h>

typedef struct _varchar16 {
	int16_t len;
	char str[];
} varchar16_t;

char *vctostr(varchar16_t *vc);
