#include <stdio.h>
#include <string.h>

#include <qusec.h>
#include <qmhsndpm.h>

#include "sndmsg.h"

void send_message(const char *message, const char *type)
{
	Qus_EC_t err;
	char key[4];

	memset(&err, 0, sizeof(err));
	err.Bytes_Provided = sizeof(err);

	/* XXX: switch the call stack entry so it displays the parent instead */
	QMHSNDPM((char*)message, MSG_FILE, "", 0, (char*)type, "*PGMBDY   ", 1, &key, &err);
	if ('\0' != err.Exception_Id[0]) {
		err.Reserved = '\0';
		fprintf(stderr, "QMHSNDPM error: %s\n", err.Exception_Id);
	}
}

void send_message_int(const char *message, const char *type, int data)
{
	Qus_EC_t err;
	char key[4];

	memset(&err, 0, sizeof(err));
	err.Bytes_Provided = sizeof(err);

	QMHSNDPM((char*)message, MSG_FILE, &data, sizeof(data), (char*)type, "*PGMBDY   ", 1, &key, &err);
	if ('\0' != err.Exception_Id[0]) {
		err.Reserved = '\0';
		fprintf(stderr, "QMHSNDPM error: %s\n", err.Exception_Id);
	}
}

