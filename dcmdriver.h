void send_message_driver(char *);

void ensure_libl(void);

/*
 * This undocumented program is used by the DCM web API.
 * The reason why it uses an environment variable as it's how Net.Data gets
 * external data, *not* via the typical OPM calling convention.
 *
 * Function codes and their expected arguments can be found in the directories
 * of the Net.Data code for DCM:
 *  - /QIBM/ProdData/ICSS/Cert/Macro
 *  - /QIBM/ProdData/HTTP/Protect/ICSS/Cert/Macro
 *
 * Note that some arguments may crash the driver with unexpected data.
 * (So much for defensive programming!)
 * It is also assumed you have proper authorities... which aren't documented.
 *
 * Some functions are reasonably implementable with the public API instead.
 * (Assuming the API you want is exposed and on the version of i, of course.)
 * It can be quirky and leak abstractions, but it's far saner than poking
 * undocumented internal-for-DCM programs!
 *
 * Arguments: Function, environment variable, [more args]
 */
#pragma linkage (QYCUDRIVER, OS, nowiden)
void QYCUDRIVER(char*, char*, ...); /* QICSS/QYCUDRIVER */

