#include <stdlib.h>
#include <unistd.h>

#include "dcmdriver.h"
#include "sndmsg.h"
#include "unsetenv.h"
#include "varchar.h"

int main (int argc, char **argv)
{
	/* Args */
	char *keystore = NULL, *kspw = NULL, *label = NULL, *driverret;
	ensure_libl();
	keystore = vctostr((varchar16_t*)argv[1]);
	if (access(keystore, R_OK) != 0) {
		send_message("ACM0103", MSG_COMP);
		goto finish;
	}
	kspw = vctostr((varchar16_t*)argv[2]);
	label = vctostr((varchar16_t*)argv[3]);
	QYCUDRIVER("24", "DRIVER_RETURN", keystore, kspw, label);
	driverret = getenv("DRIVER_RETURN");
	send_message_driver(driverret, MSG_COMP);
finish:
	unsetenv("DRIVER_RETURN");
	free(keystore);
	free(kspw);
	free(label);
	return 0;
}
