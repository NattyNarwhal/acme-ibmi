/* I'm sorry, but what? */
#define __cplusplus__strings__ 1

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <sys/stat.h>
#include <sys/wait.h>

#include <qp2user.h>

#include "dcmdriver.h"
#include "ebcdic.h"
#include "sndmsg.h"
#include "unsetenv.h"
#include "varchar.h"

#define OPENSSL_PGM "/QOpenSys/usr/bin/openssl"

static char* tempfilename(char *purpose)
{
	/* we don't have mkdtemp, we don't have asprintf either! losing! */
	char name[1024];
	snprintf(name, 1024, "/tmp/acmewrap-%d.%s", getpid(), purpose);
	return strdup(name);
}

/*
 * This should be less... fragile/racy. Avoid shelling out to external programs.
 * It has the issues of being clumsy, but also a security risk - argv/env can be
 * read by other processes. We should be talking to a PASE worker through dlopen
 * symbols, since ILE/PASE talking via pipes seems to be made harder...
 */
static int convert_pem_to_pkcs12(char *in, char *inkey, char *out, char *pw)
{
	char *pwfile = NULL, *pwarg = NULL, *pwutf = NULL;
	char *rndfile = NULL, *rndenv = NULL; /* rndfile is bc openssl */
	FILE *pwfp;
	int ret;
	ret = -1;
	pwfile = tempfilename("osslpw");
	pwarg = malloc(6 + strlen(pwfile));
	if (pwarg == NULL)
		return -1;
	snprintf(pwarg, 6 + strlen(pwfile), "file:%s", pwfile);
	/*
	 * QYCUDRIVER will convert our EBCDIC value to not-EBCDIC.
	 * Make sure OpenSSL will get a not-EBCDIC value too.
	 */
	pwfp = fopen(pwfile, "w, o_ccsid=1208");
	if (pwfp == NULL) {
		perror("aaaaa");
		goto finish;
	}
	pwutf = ebcdic2utf_alloc(pw, strlen(pw));
	if (pwutf == NULL) {
		goto finish;
	}
	fwrite(pwutf, strlen(pwutf), 1, pwfp);
	fclose(pwfp);
	rndfile = tempfilename("rnd");
	rndenv = malloc(10 + strlen(rndfile));
	if (rndfile == NULL || rndenv == NULL) {
		goto finish;
	}
	snprintf(rndenv, 10 + strlen(rndfile), "RANDFILE=%s", rndfile);
	char *pase_argv[] = {
		OPENSSL_PGM,
		"pkcs12",
		"-export",
		"-in",
		in,
		"-inkey",
		inkey,
		"-out",
		out,
		"-password",
		pwarg,
		NULL
	};
	char *pase_envp[] = { rndenv, NULL };
	ret = Qp2RunPase(OPENSSL_PGM, NULL, NULL, 0, 1208, pase_argv, pase_envp);
finish:
	if (rndfile != NULL) {
		unlink(rndfile);
		free(rndfile);
	}
	if (pwfile != NULL) {
		unlink(pwfile);
		free(pwfile);
	}
	free(pwutf);
	free(pwarg);
	free(rndenv);
	return ret;
}

int main (int argc, char **argv)
{
	int paseret;
	mode_t oldmask;
	char *crtfile, *driverret;
	/* If we're converting it temporarily, the file name to use. */
	char *crttemp = NULL;
	/* Args */
	char *keystore = NULL, *kspw = NULL, *crt = NULL, *crtkey = NULL;
	char *crtpw = NULL, *crttype = NULL, *label = NULL;
	keystore = vctostr((varchar16_t*)argv[1]);
	if (access(keystore, R_OK) != 0) {
		send_message("ACM0103", MSG_COMP);
		goto finish;
	}
	kspw = vctostr((varchar16_t*)argv[2]);
	crt = vctostr((varchar16_t*)argv[3]);
	if (access(keystore, R_OK) != 0) {
		send_message("ACM0104", MSG_COMP);
		goto finish;
	}
	crtkey = vctostr((varchar16_t*)argv[4]);
	crtpw = vctostr((varchar16_t*)argv[5]);
	/* Surprise! This doesn't need to be a varchar. */
	crttype = argv[6];
	label = vctostr((varchar16_t*)argv[7]);
	/* If we have a PEM certificate, make a temporary PKCS file */
	if (memcmp(crttype, "*PKCS12", 7) == 0) {
		if (strlen(crtkey) > 0) {
			send_message("ACM0101", MSG_INFO);
		}
		crtfile = crt;
	} else if (memcmp(crttype, "*PEM   ", 7) == 0) { /* *PEM */
		if (strlen(crtkey) <= 0) {
			send_message("ACM0102", MSG_COMP);
			goto finish;
		}
		if (access(crtkey, R_OK) != 0) {
			send_message("ACM0102", MSG_COMP);
			goto finish;
		}
		/* Ugly shenanigans to make a temporary file... */
		oldmask = umask(0077);
		crttemp = tempfilename("pkcs12");
		if (crtpw == NULL || strlen(crtpw) == 0) {
			free(crtpw);
			crtpw = strdup(crttemp); /* probably unwise */
		}
		/* Now convert with OpenSSL... (XXX: less scripty way) */
		paseret = convert_pem_to_pkcs12(crt, crtkey, crttemp, crtpw);
		if (!(WIFEXITED(paseret) && WEXITSTATUS(paseret) == 0)) {
			send_message_int("ACM0107", MSG_COMP, paseret);
			goto finish;
		}
		umask(oldmask);
		crtfile = crttemp;
	} else {
		send_message("ACM0106", MSG_COMP);
		goto finish;
	}
	/* Run driver, then fall through to cleanup */
	if (label == NULL || strlen(label) <= 0 || memcmp(label, "*NONE", 5) == 0) {
		QYCUDRIVER("31", "DRIVER_RETURN", keystore, kspw, crtfile, crtpw, "1");
	} else {
		QYCUDRIVER("107", "DRIVER_RETURN", keystore, kspw, crtfile, crtpw, label);
	}
	driverret = getenv("DRIVER_RETURN");
	if (driverret == NULL || atoi(driverret) != 0) {
		send_message_int("ACM0108", MSG_COMP, atoi(driverret));
		goto finish;
	}
	send_message("ACM0000", MSG_COMP);
finish:
	unsetenv("DRIVER_RETURN");
	free(keystore);
	free(kspw);
	free(crt);
	free(crtkey);
	free(crtpw);
	free(label);
	/* We're done with any temporary files we had to make. */
	if (crttemp != NULL) {
		unlink(crttemp);
		free(crttemp);
	}
	return 0;
}
