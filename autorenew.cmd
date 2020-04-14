             CMD        PROMPT('Auto Renew Cert')
             PARM       KWD(KEYSTORE) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Keystore File') +
                          FILE(*IN) VARY(*YES)
             PARM       KWD(KSPW) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Keystore Password') +
                          VARY(*YES)
             /* Assume PEM */
             PARM       KWD(CRT) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Certificate') FILE(*IN) +
                          VARY(*YES)
             PARM       KWD(CRTKEY) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Certificate Key') +
                          FILE(*IN) VARY(*YES)
             PARM       KWD(DOMAIN) TYPE(*CHAR) LEN(255) MIN(1) PROMPT('Domain')
             PARM       KWD(FORCE) TYPE(*LGL) LEN(1) PROMPT('Force Renewal') DFT('0')
