             CMD        PROMPT('Add DCM Certificate')
             PARM       KWD(KEYSTORE) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Keystore File') +
                          FILE(*IN) VARY(*YES)
             PARM       KWD(KSPW) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Keystore Password') +
                          VARY(*YES)
             /* Annoyingly, keys *have* to be in PKCS#12, but acme-client wants PEM. */
             /* We'll have to do some intermediate conversion in the program, bleh. */
             PARM       KWD(CRT) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Certificate') FILE(*IN) +
                          VARY(*YES)
             PARM       KWD(CRTKEY) TYPE(*CHAR) LEN(1024) PROMPT('Certificate Key (PEM)') +
                          FILE(*IN) VARY(*YES)
             /* Assuming *PEM -> CRTPW == '' */
             PARM       KWD(CRTPW) TYPE(*CHAR) LEN(1024) PROMPT('Certificate Password') +
                          VARY(*YES)
             PARM       KWD(CRTTYPE) TYPE(*CHAR) LEN(7) PROMPT('Certificate Type') RSTD(*YES) +
                          SPCVAL(*PEM *PKCS12) DFT(*PEM)
             /* QYCUDRIVER has diff functions for if you use a label or not */
             PARM       KWD(LABEL) TYPE(*CHAR) LEN(1024) PROMPT('Label') DFT(*NONE) +
                          VARY(*YES) SPCVAL(*NONE)
 
