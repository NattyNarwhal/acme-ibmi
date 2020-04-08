#include <stdlib.h>
#include <string.h>

#include "varchar.h"

/* Effectivelly a strdup, but works on a varchar when it isn't NULL at end */
char *vctostr(varchar16_t *vc)
{
	char *str;
	str = malloc(vc->len + 1);
	if (str == NULL)
		return NULL;
	memcpy(str, vc->str, vc->len);
	str[vc->len + 1] = '\0';
	return str;
}
