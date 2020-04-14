#include <stdlib.h>
#include <unistd.h>

#include "dcmdriver.h"
#include "sndmsg.h"
#include "unsetenv.h"
#include "varchar.h"

int main (int argc, char **argv)
{
	char *driverret;
	/* Args */
	char *keystore = NULL, *kspw = NULL, *crt = NULL, *label = NULL;
	ensure_libl();
	keystore = vctostr((varchar16_t*)argv[1]);
	if (access(keystore, R_OK) != 0) {
		send_message("ACM0103", MSG_DIAG);
		send_message("ACM0103", MSG_STATUS);
		goto finish;
	}
	kspw = vctostr((varchar16_t*)argv[2]);
	crt = vctostr((varchar16_t*)argv[3]);
	if (access(crt, R_OK) != 0) {
		send_message("ACM0104", MSG_DIAG);
		send_message("ACM0104", MSG_STATUS);
		goto finish;
	}
	label = vctostr((varchar16_t*)argv[4]);
	/* Run driver, then fall through to cleanup */
	QYCUDRIVER("67", "DRIVER_RETURN", keystore, kspw, label, crt, "1");
	driverret = getenv("DRIVER_RETURN");
	send_message_driver(driverret);
finish:
	unsetenv("DRIVER_RETURN");
	free(keystore);
	free(kspw);
	free(crt);
	free(label);
	return 0;
}
