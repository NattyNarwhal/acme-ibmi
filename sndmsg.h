/*
 * Sending a message can be annoyingly verbose. Try to make sending simple
 * messages simple.
 */
#define MSG_FILE "MESSAGES  " "ACME      "
#define MSG_COMP "*COMP     "
#define MSG_INFO "*INFO     "
#define MSG_DIAG "*DIAG     "

void send_message(const char *, const char *);
void send_message_int(const char *, const char *, int);
