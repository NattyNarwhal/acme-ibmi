/*
 * Sending a message can be annoyingly verbose. Try to make sending simple
 * messages simple.
 */
#define MSG_FILE "MESSAGES  " "ACME      "
#define MSG_COMP "*COMP     "
#define MSG_INFO "*INFO     "

void send_message(const char *, const char *);
void send_message_int(const char *, const char *, int);
