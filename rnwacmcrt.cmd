             CMD        PROMPT('Renew ACME Certificate')
             PARM       KWD(DOMAIN) TYPE(*CHAR) LEN(255) MIN(1) PROMPT('Domain')
             PARM       KWD(FORCE) TYPE(*LGL) LEN(1) PROMPT('Force Renewal') DFT('0')
             /* Limitations: The fact we must use acme-client.conf for now. */
 
