#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "sndmsg.h"

/*
 * Our message file has a special DCM prefix for DCM messages.
 * We will assume DCM messages are capped to int16_t.
 */
void send_message_dcm(int ret, char *type)
{
	char msgid[8];
	if (ret < SHRT_MIN || ret > SHRT_MAX) {
		send_message_int("ACM0108", type, ret);
		return;
	}
	snprintf(msgid, 8, "DRV%04X", (int16_t)ret);
	send_message(msgid, type);
}

/*
 * The DCM driver returns errors that can be matched up with Net.Data files for
 * the DCM web UI. You can do something like "grep -R 21 /QIBM/ProdData/ICSS/"
 * followed by the constant name you can scrounge up to ascertain its purpose.
 *
 * This function will try to send an appropriate program message for codes,
 * falling back or succeeding as needed.
 */
void send_message_driver(char *ret, char *type)
{
	int iret;
	if (ret == NULL) {
		send_message("ACM0109", type);
		return;
	}
	iret = atoi(ret);
	switch (iret) {
	default:
		send_message_int("ACM0108", type, iret);
		break;
	case 0: /* Success */
		send_message("ACM0000", type);
		break;
	/* DCM driver returnables that we know of */
	/* XXX: Check/handle if message (doesn't) exist so we don't need to have this */
	case 16: /* Invalid keystore password */
	case 21: /* Duplicate key(/label?) */
	case 34: /* Validation error */
	case 78: /* Error opening file */
	case 85: /* Invalid b64 */
	case 109: /* No label */
	case 325: /* Failed to copy to keystore */
	case 330: /* Renewal doesn't match anything */
	case 365: /* PKCS#12 digest error */
		send_message_dcm(iret, type);
		break;
	}
}

/* HACK: QICSS must be on our library list. Make it so. */
void ensure_libl(void)
{
	/* XXX: should use qlichgll */
	system("addlible qicss");
}
