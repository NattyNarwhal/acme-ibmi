QSYS := /QSYS.LIB
LIB_NAME := ACME
LIB_PATH := $(QSYS)/$(LIB_NAME).LIB

ADDMSGD := system addmsgd
CRTBNDC := system crtbndc
CRTBNDC_OPTS := "SYSIFCOPT(*IFSIO)" #"output(*PRINT)"
CRTCMD := system crtcmd
CRTCMD_OPTS := "THDSAFE(*YES)"
CRTCMOD := system crtcmod
CRTCMOD_OPTS := "SYSIFCOPT(*IFSIO)" #"output(*PRINT)"
CRTLIB := system crtlib
CRTPGM := system crtpgm
CRTPGM_OPTS := #"bndsrvpgm(QICSS/QYCUCERTI)"

PREFIX := /QOpenSys/Acme

.PHONY: all clean test dist

all: $(LIB_PATH)/ADDDCMCA.CMD $(LIB_PATH)/ADDDCMCRT.CMD $(LIB_PATH)/AUTORENEW.CMD $(LIB_PATH)/RMVDCMCRT.CMD $(LIB_PATH)/RNWACMCRT.CMD $(LIB_PATH)/RNWDCMCRT.CMD $(LIB_PATH)/RVKACMCRT.CMD $(LIB_PATH)/MESSAGES.MSGF

clean:
	rm -f config.h
	system dltlib $(LIB_NAME)

config.h:
	echo "/* These configuration values are derived from the Makefile */" > config.h
	echo "#define OPENSSL_PGM \"`which openssl`\"" >> config.h
	echo "#define PASE_PGM \"$(PREFIX)/libexec/wrap-acme-client\"" >> config.h

install: config.h
	# Assume ILE components should be built now. We will install PASE components into IFS.
	mkdir -p -m 0755 "$(PREFIX)/libexec"
	install -m 0755 -o 0 wrap-acme-client "$(PREFIX)/libexec/wrap-acme-client"

# Messages
$(LIB_PATH)/MESSAGES.MSGF: $(LIB_PATH) Makefile
	system dltmsgf "MSGF($(LIB_NAME)/MESSAGES)" || true
	system crtmsgf "MSGF($(LIB_NAME)/MESSAGES)" "TEXT('ACME wrapper messages')"
	$(ADDMSGD) "MSGID(ACM0000)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Action succeeded.')" "SEV(00)"
	$(ADDMSGD) "MSGID(ACM0001)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Action failed with result &1.')" "FMT((*BIN 4))" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM0002)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Renewal unneeded.')" "SEV(10)"
	$(ADDMSGD) "MSGID(ACM0101)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('PEM key not needed.')" "SEV(10)"
	$(ADDMSGD) "MSGID(ACM0102)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('PEM key required to convert.')" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM0103)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Keystore file inaccessible.')" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM0104)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Certificate file inaccessible.')" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM0105)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('PEM key file inaccessible.')" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM0106)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Unknown certificate type.')" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM0107)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Failed to convert certificate with result &1.')" "FMT((*BIN 4))" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM0108)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('DCM driver returned result &1.')" "FMT((*BIN 4))" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM0109)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('DCM driver returned no result.')" "SEV(30)"
	$(ADDMSGD) "MSGID(ACM010A)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Certificate password required.')" "SEV(30)"
	# Here begins the DCM driver messages
	$(ADDMSGD) "MSGID(DRV0010)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Invalid keystore password.')" "SEV(30)"
	$(ADDMSGD) "MSGID(DRV0015)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Duplicate key/label.')" "SEV(30)"
	$(ADDMSGD) "MSGID(DRV0022)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Certificate validation error; is the issuer in the keystore and enabled?')" "SEV(30)"
	$(ADDMSGD) "MSGID(DRV004E)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Error opening file.')" "SEV(30)"
	$(ADDMSGD) "MSGID(DRV0055)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Invalid Base64 data.')" "SEV(30)"
	$(ADDMSGD) "MSGID(DRV006D)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('No key exists with that label.')" "SEV(30)"
	$(ADDMSGD) "MSGID(DRV0145)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('Failed to copy the object to a keystore.')" "SEV(30)"
	$(ADDMSGD) "MSGID(DRV014A)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('No certificates match for renewal.')" "SEV(30)"
	$(ADDMSGD) "MSGID(DRV016D)" "MSGF($(LIB_NAME)/MESSAGES)" "MSG('PKCS#12 digest failure; is the password correct?')" "SEV(30)"

# Commands
$(LIB_PATH)/QCMDSRC.FILE: $(LIB_PATH)
	system dltf "file(acme/qcmdsrc)" || true
	system crtsrcpf "rcdlen(112)" "file(acme/qcmdsrc)"

$(LIB_PATH)/QCMDSRC.FILE/ADDDCMCA.MBR: $(LIB_PATH)/QCMDSRC.FILE adddcmca.cmd
	system rmvm "file(acme/qcmdsrc)" "mbr(adddcmca)" || true
	system addpfm "file(acme/qcmdsrc)" "mbr(adddcmca)"
	system cpyfrmstmf "mbropt(*replace)" "fromstmf(adddcmca.cmd)" "tombr('$(LIB_PATH)/QCMDSRC.FILE/ADDDCMCA.MBR')"

$(LIB_PATH)/QCMDSRC.FILE/ADDDCMCRT.MBR: $(LIB_PATH)/QCMDSRC.FILE adddcmcrt.cmd
	system rmvm "file(acme/qcmdsrc)" "mbr(adddcmcrt)" || true
	system addpfm "file(acme/qcmdsrc)" "mbr(adddcmcrt)"
	system cpyfrmstmf "mbropt(*replace)" "fromstmf(adddcmcrt.cmd)" "tombr('$(LIB_PATH)/QCMDSRC.FILE/ADDDCMCRT.MBR')"

$(LIB_PATH)/QCMDSRC.FILE/AUTORENEW.MBR: $(LIB_PATH)/QCMDSRC.FILE autorenew.cmd
	system rmvm "file(acme/qcmdsrc)" "mbr(autorenew)" || true
	system addpfm "file(acme/qcmdsrc)" "mbr(autorenew)"
	system cpyfrmstmf "mbropt(*replace)" "fromstmf(autorenew.cmd)" "tombr('$(LIB_PATH)/QCMDSRC.FILE/AUTORENEW.MBR')"

$(LIB_PATH)/QCMDSRC.FILE/RMVDCMCRT.MBR: $(LIB_PATH)/QCMDSRC.FILE rmvdcmcrt.cmd
	system rmvm "file(acme/qcmdsrc)" "mbr(rmvdcmcrt)" || true
	system addpfm "file(acme/qcmdsrc)" "mbr(rmvdcmcrt)"
	system cpyfrmstmf "mbropt(*replace)" "fromstmf(rmvdcmcrt.cmd)" "tombr('$(LIB_PATH)/QCMDSRC.FILE/RMVDCMCRT.MBR')"

$(LIB_PATH)/QCMDSRC.FILE/RNWACMCRT.MBR: $(LIB_PATH)/QCMDSRC.FILE rnwacmcrt.cmd
	system rmvm "file(acme/qcmdsrc)" "mbr(rnwacmcrt)" || true
	system addpfm "file(acme/qcmdsrc)" "mbr(rnwacmcrt)"
	system cpyfrmstmf "mbropt(*replace)" "fromstmf(rnwacmcrt.cmd)" "tombr('$(LIB_PATH)/QCMDSRC.FILE/RNWACMCRT.MBR')"

$(LIB_PATH)/QCMDSRC.FILE/RNWDCMCRT.MBR: $(LIB_PATH)/QCMDSRC.FILE rnwdcmcrt.cmd
	system rmvm "file(acme/qcmdsrc)" "mbr(rnwdcmcrt)" || true
	system addpfm "file(acme/qcmdsrc)" "mbr(rnwdcmcrt)"
	system cpyfrmstmf "mbropt(*replace)" "fromstmf(rnwdcmcrt.cmd)" "tombr('$(LIB_PATH)/QCMDSRC.FILE/RNWDCMCRT.MBR')"

$(LIB_PATH)/QCMDSRC.FILE/RVKACMCRT.MBR: $(LIB_PATH)/QCMDSRC.FILE rvkacmcrt.cmd
	system rmvm "file(acme/qcmdsrc)" "mbr(rvkacmcrt)" || true
	system addpfm "file(acme/qcmdsrc)" "mbr(rvkacmcrt)"
	system cpyfrmstmf "mbropt(*replace)" "fromstmf(rvkacmcrt.cmd)" "tombr('$(LIB_PATH)/QCMDSRC.FILE/RVKACMCRT.MBR')"

$(LIB_PATH)/ADDDCMCA.CMD: $(LIB_PATH)/QCMDSRC.FILE/ADDDCMCA.MBR $(LIB_PATH)/ADDDCMCA.PGM
	system dltcmd "cmd(acme/adddcmca)" || true
	$(CRTCMD) $(CRTCMD_OPTS) "cmd(acme/adddcmca)" "srcfile(acme/qcmdsrc)" "pgm(acme/adddcmca)"

$(LIB_PATH)/ADDDCMCRT.CMD: $(LIB_PATH)/QCMDSRC.FILE/ADDDCMCRT.MBR $(LIB_PATH)/ADDDCMCRT.PGM
	system dltcmd "cmd(acme/adddcmcrt)" || true
	$(CRTCMD) $(CRTCMD_OPTS) "cmd(acme/adddcmcrt)" "srcfile(acme/qcmdsrc)" "pgm(acme/adddcmcrt)"

$(LIB_PATH)/AUTORENEW.CMD: $(LIB_PATH)/QCMDSRC.FILE/AUTORENEW.MBR $(LIB_PATH)/AUTORENEW.PGM
	system dltcmd "cmd(acme/adddcmcrt)" || true
	$(CRTCMD) $(CRTCMD_OPTS) "cmd(acme/autorenew)" "srcfile(acme/qcmdsrc)" "pgm(acme/autorenew)"

$(LIB_PATH)/RMVDCMCRT.CMD: $(LIB_PATH)/QCMDSRC.FILE/RMVDCMCRT.MBR $(LIB_PATH)/RMVDCMCRT.PGM
	system dltcmd "cmd(acme/rmvdcmcrt)" || true
	$(CRTCMD) $(CRTCMD_OPTS) "cmd(acme/rmvdcmcrt)" "srcfile(acme/qcmdsrc)" "pgm(acme/rmvdcmcrt)"

$(LIB_PATH)/RNWACMCRT.CMD: $(LIB_PATH)/QCMDSRC.FILE/RNWACMCRT.MBR $(LIB_PATH)/RNWACMCRT.PGM
	system dltcmd "cmd(acme/rnwacmcrt)" || true
	$(CRTCMD) $(CRTCMD_OPTS) "cmd(acme/rnwacmcrt)" "srcfile(acme/qcmdsrc)" "pgm(acme/rnwacmcrt)"

$(LIB_PATH)/RNWDCMCRT.CMD: $(LIB_PATH)/QCMDSRC.FILE/RNWDCMCRT.MBR $(LIB_PATH)/RNWDCMCRT.PGM
	system dltcmd "cmd(acme/rnwdcmcrt)" || true
	$(CRTCMD) $(CRTCMD_OPTS) "cmd(acme/rnwdcmcrt)" "srcfile(acme/qcmdsrc)" "pgm(acme/rnwdcmcrt)"

$(LIB_PATH)/RVKACMCRT.CMD: $(LIB_PATH)/QCMDSRC.FILE/RVKACMCRT.MBR $(LIB_PATH)/RVKACMCRT.PGM
	system dltcmd "cmd(acme/rvkacmcrt)" || true
	$(CRTCMD) $(CRTCMD_OPTS) "cmd(acme/rvkacmcrt)" "srcfile(acme/qcmdsrc)" "pgm(acme/rvkacmcrt)"

# Programs
$(LIB_PATH)/ADDDCMCA.PGM: $(LIB_PATH)/ADDDCMCA.MODULE $(LIB_PATH)/SNDMSG.MODULE $(LIB_PATH)/VARCHAR.MODULE $(LIB_PATH)/DCMDRIVER.MODULE
	$(CRTPGM) $(CRTPGM_OPTS) "PGM($(LIB_NAME)/ADDDCMCA)" "MODULE($(LIB_NAME)/ADDDCMCA $(LIB_NAME)/DCMDRIVER $(LIB_NAME)/SNDMSG $(LIB_NAME)/VARCHAR)"

$(LIB_PATH)/ADDDCMCRT.PGM: $(LIB_PATH)/ADDDCMCRT.MODULE $(LIB_PATH)/SNDMSG.MODULE $(LIB_PATH)/VARCHAR.MODULE $(LIB_PATH)/EBCDIC.MODULE $(LIB_PATH)/DCMDRIVER.MODULE
	$(CRTPGM) $(CRTPGM_OPTS) "PGM($(LIB_NAME)/ADDDCMCRT)" "MODULE($(LIB_NAME)/ADDDCMCRT $(LIB_NAME)/DCMDRIVER $(LIB_NAME)/EBCDIC $(LIB_NAME)/SNDMSG $(LIB_NAME)/VARCHAR)"

$(LIB_PATH)/AUTORENEW.PGM: $(LIB_PATH)/AUTORENEW.MODULE $(LIB_PATH)/VARCHAR.MODULE
	$(CRTPGM) $(CRTPGM_OPTS) "PGM($(LIB_NAME)/AUTORENEW)" "MODULE($(LIB_NAME)/AUTORENEW $(LIB_NAME)/VARCHAR)"

$(LIB_PATH)/RMVDCMCRT.PGM: $(LIB_PATH)/RMVDCMCRT.MODULE $(LIB_PATH)/SNDMSG.MODULE $(LIB_PATH)/VARCHAR.MODULE $(LIB_PATH)/DCMDRIVER.MODULE
	$(CRTPGM) $(CRTPGM_OPTS) "PGM($(LIB_NAME)/RMVDCMCRT)" "MODULE($(LIB_NAME)/RMVDCMCRT $(LIB_NAME)/DCMDRIVER $(LIB_NAME)/SNDMSG $(LIB_NAME)/VARCHAR)"

$(LIB_PATH)/RNWACMCRT.PGM: $(LIB_PATH)/RNWACMCRT.MODULE $(LIB_PATH)/SNDMSG.MODULE
	$(CRTPGM) $(CRTPGM_OPTS) "PGM($(LIB_NAME)/RNWACMCRT)" "MODULE($(LIB_NAME)/RNWACMCRT $(LIB_NAME)/SNDMSG)"

$(LIB_PATH)/RNWDCMCRT.PGM: $(LIB_PATH)/RNWDCMCRT.MODULE $(LIB_PATH)/SNDMSG.MODULE $(LIB_PATH)/VARCHAR.MODULE $(LIB_PATH)/DCMDRIVER.MODULE
	$(CRTPGM) $(CRTPGM_OPTS) "PGM($(LIB_NAME)/RNWDCMCRT)" "MODULE($(LIB_NAME)/RNWDCMCRT $(LIB_NAME)/DCMDRIVER $(LIB_NAME)/SNDMSG $(LIB_NAME)/VARCHAR)"

$(LIB_PATH)/RVKACMCRT.PGM: $(LIB_PATH)/RVKACMCRT.MODULE $(LIB_PATH)/SNDMSG.MODULE
	$(CRTPGM) $(CRTPGM_OPTS) "PGM($(LIB_NAME)/RVKACMCRT)" "MODULE($(LIB_NAME)/RVKACMCRT $(LIB_NAME)/SNDMSG)"

# Modules
$(LIB_PATH)/ADDDCMCA.MODULE: $(LIB_PATH) adddcmca.c dcmdriver.h sndmsg.h unsetenv.h varchar.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/ADDDCMCA)" "SRCSTMF('adddcmca.c')"

$(LIB_PATH)/ADDDCMCRT.MODULE: $(LIB_PATH) adddcmcrt.c dcmdriver.h sndmsg.h unsetenv.h varchar.h config.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/ADDDCMCRT)" "SRCSTMF('adddcmcrt.c')"

$(LIB_PATH)/AUTORENEW.MODULE: $(LIB_PATH) autorenew.c varchar.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/AUTORENEW)" "SRCSTMF('autorenew.c')"

$(LIB_PATH)/DCMDRIVER.MODULE: $(LIB_PATH) dcmdriver.c sndmsg.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/DCMDRIVER)" "SRCSTMF('dcmdriver.c')"

$(LIB_PATH)/EBCDIC.MODULE: $(LIB_PATH) ebcdic.c
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/EBCDIC)" "SRCSTMF('ebcdic.c')"

$(LIB_PATH)/RMVDCMCRT.MODULE: $(LIB_PATH) rmvdcmcrt.c  dcmdriver.h sndmsg.h unsetenv.h varchar.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/RMVDCMCRT)" "SRCSTMF('rmvdcmcrt.c')"

$(LIB_PATH)/RNWACMCRT.MODULE: $(LIB_PATH) rnwacmcrt.c sndmsg.h config.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/RNWACMCRT)" "SRCSTMF('rnwacmcrt.c')"

$(LIB_PATH)/RNWDCMCRT.MODULE: $(LIB_PATH) rnwdcmcrt.c dcmdriver.h sndmsg.h unsetenv.h varchar.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/RNWDCMCRT)" "SRCSTMF('rnwdcmcrt.c')"

$(LIB_PATH)/RVKACMCRT.MODULE: $(LIB_PATH) rvkacmcrt.c sndmsg.h config.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/RVKACMCRT)" "SRCSTMF('rvkacmcrt.c')"

$(LIB_PATH)/SNDMSG.MODULE: $(LIB_PATH) sndmsg.c sndmsg.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/SNDMSG)" "SRCSTMF('sndmsg.c')"

$(LIB_PATH)/VARCHAR.MODULE: $(LIB_PATH) varchar.c varchar.h
	$(CRTCMOD) $(CRTCMOD_OPTS) "MODULE($(LIB_NAME)/VARCHAR)" "SRCSTMF('varchar.c')"

# Libraries
$(LIB_PATH):
	$(CRTLIB) $(LIB_NAME) "TEXT('ACME wrapper')"
