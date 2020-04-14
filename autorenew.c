/*
 * Current issues:
 *  - autorenew doesn't display messages on the status line.
 *    not a big deal, since it's intendded to be used batch/scheduled,
 *    versus the other commands being OK for it
 *  - it requires the commands it uses double up on DIAG then STATUS
 *    the double status thing is annoying, ugh
 *  - you still see the duplicate label exception. could handle it better
 *    ...or actually check for the damn lavel first
 *    (ILE exception handling is gross! and MONMSG! maybe receive program
 *     message sucks less?)
 *    ...or maybe i'll have to refactor this as a library
 *    ...or a CLP
 */
#include <except.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "varchar.h"

/* Dramatis personae */
#pragma linkage (ADDDCMCRT, OS, nowiden)
void ADDDCMCRT(varchar16_t*, varchar16_t*, varchar16_t*, varchar16_t*, varchar16_t*, char*, varchar16_t*);
#pragma linkage (RNWACMCRT, OS, nowiden)
void RNWACMCRT(char*, char*);
#pragma linkage (RNWDCMCRT, OS, nowiden)
void RNWDCMCRT(varchar16_t*, varchar16_t*, varchar16_t*);

static void init_flexibles(varchar16_t **crtpw, varchar16_t **label)
{
	*crtpw = malloc(2 + 1024);
	memset(*crtpw, 0, 2 + 1024);
	*label = malloc(2 + 255);
	memset(*label, 0, 2 + 255);
	(*label)->len = 5;
	memcpy((*label)->str, "*NONE", 5);
}

int main (int argc, char **argv)
{
	varchar16_t *keystore = NULL, *kspw = NULL, *crt = NULL, *crtkey = NULL;
	char *domain, *force; /* not varchar... yet */
	/* constants */
	varchar16_t *label, *crtpw;
	char *crttype = "*PEM   ";
	init_flexibles(&crtpw, &label);
	/* let the programs valid their arguments */
	keystore = (varchar16_t*)argv[1];
	kspw = (varchar16_t*)argv[2];
	crt = (varchar16_t*)argv[3];
	crtkey = (varchar16_t*)argv[4];
	domain = argv[5];
	force = argv[6];
	/* This is thrown if acme-client decides renewal is unnecessary */
#pragma exception_handler(FINISH, 0, _C1_ALL, _C2_ALL, _CTLA_HANDLE, "ACM0002")
	/* This is thrown if acme-client barfs (check the logs!) */
#pragma exception_handler(FINISH, 0, _C1_ALL, _C2_ALL, _CTLA_HANDLE, "ACM0001")
	RNWACMCRT(domain, force);
	/* This is thrown if the cert exists, so we need to renew for DCM */
#pragma exception_handler(EXISTING, 0, _C1_ALL, _C2_ALL, _CTLA_HANDLE, "DRV0015")
	ADDDCMCRT(keystore, kspw, crt, crtkey, crtpw, crttype, label);
	goto FINISH;
EXISTING:
	RNWDCMCRT(keystore, kspw, crt);
FINISH:
	return 0;
}
