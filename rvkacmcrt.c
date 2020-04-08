#include <sys/wait.h>
#include <qp2user.h>

#include "sndmsg.h"

#define PASE_PGM "/home/CALVIN/acme/libexec/acme/wrap-acme-client"

/*
 * Parm 1: domain, 255-byte fixed length string, padded by spaces. truncate or else
 */
int main (int argc, char **argv)
{
	int i, ret;
	char *domain, *pase_argv[4];

	for (i = 0; i < 255; i++) {
		if (argv[1][i] == ' ' || i == 254) {
			argv[1][i] = '\0';
			break;
		}
	}
	domain = argv[1];
	/* bleh, we can't assign an array */
	pase_argv[0] = PASE_PGM;
	pase_argv[1] = "-r";
	pase_argv[2] = domain;
	pase_argv[3] = NULL;
	ret = Qp2RunPase(PASE_PGM, NULL, NULL, 0, 1208, pase_argv, NULL);
#if 0
	fprintf(stderr, "error code %d\x25", ret);
#endif
	if (WIFEXITED(ret)) {
		ret = WEXITSTATUS(ret);
		if (ret == 0) {
			send_message("ACM0000", MSG_COMP);
			return 0;
		}
	}
	/* XXX: fancy would be capturing stdio */
	send_message("ACM0001", MSG_COMP);
	return 1;
}

