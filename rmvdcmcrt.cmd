             CMD        PROMPT('Remove DCM Certificate')
             PARM       KWD(KEYSTORE) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Keystore File') +
                          FILE(*IN) VARY(*YES)
             PARM       KWD(KSPW) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Keystore Password') +
                          VARY(*YES)
             PARM       KWD(LABEL) TYPE(*CHAR) LEN(1024) MIN(1) PROMPT('Label') VARY(*YES)
 
