#include <errno.h>
#include <iconv.h>
#include <limits.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <qtqiconv.h>

int create_ebcdic_to_utf8(iconv_t *conv)
{
	QtqCode_T ebcdic, utf;
	memset(&ebcdic , 0, sizeof(ebcdic));
	memset(&utf , 0, sizeof(utf));
	/* so the iconv object doesn't require resetting */
	ebcdic.shift_alternative = 1;
	ebcdic.shift_alternative = 1;
	/* XXX: Get job CCSID */
	ebcdic.CCSID = 37;
	utf.CCSID = 1208;
	*conv = QtqIconvOpen(&utf, &ebcdic); /* to, from */
	return conv->return_value;
}

char *ebcdic2utf_alloc(char *input, int input_length)
{
	/*
	 * XXX: We should be using realloc on a small buffer and make a small
	 * estimate. For now, do a naive worst-case assumption of all EBCDIC
	 * characters given being a worst-case 4-byte astral plane hellstew.
	 */
	/* i just love so much that iconv mutates arguments! */
	iconv_t conv; /* XXX: should be statically allocated? */
	char *in = input, *out, *out_orig;
	if (input_length < 1) {
		errno = EINVAL;
		return NULL;
	}
	if (create_ebcdic_to_utf8(&conv)) {
		errno = EINVAL;
		return NULL;
	}
	if ((((int64_t)input_length * 4) + 1) > INT_MAX) {
		errno = EOVERFLOW;
		return NULL;
	}
	int outmaxlen = (input_length * 4) + 1;
	out = malloc(outmaxlen);
	out_orig = out;
	size_t inleft = input_length, outleft = outmaxlen, ret;
	ret = iconv(conv, &in, &inleft, &out, &outleft);
	if (ret == -1) {
		free(out);
		errno = ECONVERT;
		return NULL;
	}
	out[ret == outmaxlen ? ret - 1 : ret] = '\0';
	iconv_close(conv);
	return out_orig;
}
