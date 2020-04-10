             CMD        PROMPT('Renew DCM Certificate')
             PARM       KWD(KEYSTORE) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Keystore File') +
                          FILE(*IN) VARY(*YES)
             PARM       KWD(KSPW) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Keystore Password') +
                          VARY(*YES)
             /* Bizarrely, this one has to be in PEM... (though it should check for base64 */
             PARM       KWD(CRT) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Certificate') FILE(*IN) +
                          VARY(*YES)
 
