#include <stdbool.h>
#include <stdio.h>
#include <sys/wait.h>
#include <qp2user.h>

#include "sndmsg.h"

#define PASE_PGM "/home/CALVIN/acme/libexec/acme/wrap-acme-client"

/*
 * Parm 1: domain, 255-byte fixed length string, padded by spaces. truncate or else
 * Parm 2: pad
 */
int main (int argc, char **argv)
{
	int i, ret;
	bool force;
	char *domain, *pase_argv[4];

	for (i = 0; i < 255; i++) {
		if (argv[1][i] == ' ' || i == 254) {
			argv[1][i] = '\0';
			break;
		}
	}
	domain = argv[1];
	force = argv[2][0] == '1';
	if (force) {
		/* bleh, we can't assign an array */
		pase_argv[0] = PASE_PGM;
		pase_argv[1] = "-F";
		pase_argv[2] = domain;
		pase_argv[3] = NULL;
	} else {
		pase_argv[0] = PASE_PGM;
		pase_argv[1] = domain;
		pase_argv[2] = NULL;
	}
	ret = Qp2RunPase(PASE_PGM, NULL, NULL, 0, 1208, pase_argv, NULL);
#if 0
	fprintf(stderr, "error code %d\x25", ret);
#endif
	if (WIFEXITED(ret)) {
		ret = WEXITSTATUS(ret);
		if (ret == 2 && !force) { /* Unnecessary to renew */
			send_message("ACM0002", MSG_COMP);
			return 0;
		} else if (ret == 0) {
			send_message("ACM0000", MSG_COMP);
			return 0;
		}
	}
	/* XXX: fancy would be capturing stdio */
	send_message("ACM0001", MSG_COMP);
	return 1;
}

