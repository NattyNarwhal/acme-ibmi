# ACME wrapper for IBM i

This provides (hopefully) idiomatic ways to manipulate an ACME client and
automate certificate management under IBM i. One of the large issues with the
platform for a while was no real way to get free certificates from Let's
Encrypt, and if you *did* manage to get a client, it was only going to get
certificates useful for PASE applications. Deploying to DCM so that ILE and
SLIC applications could use the certificates required manual intervention,
making the process clumsy when ACME is supposed to automate the process.

This consists of the following commands, with a consistent vocabulary:

* `ADDDCMCA`: Add DCM Certificate Authority. Adds a CA to DCM. Handles PEM.
* `ADDDCMCRT`: Add DCM Certificate: Adds a certificate with a private key to
  DCM. This can handle both PEM and PKCS#12 certificates, though PEM certs
  will automatically be converted to PKCS#12 temporarily as that's what DCM
  expects it to be.
* `RMVDCMCRT`: Remove DCM Certificate. (Also removes CAs.)
* `RNWACMCRT`: Renew ACME Certificate. Fetches a new ACME certificate; you
  still need to add it to DCM.
* `RNWDCMCRT`: Renew DCM Certificate. After loading up an ACME cert, you
  probably want to use this.
* `RVKACMCRT`: Revoke ACME Certificate.

These commands emit messages after invocation, and are useful for creating
your own scheduled jobs to refresh certificates.

For querying ACME servers, OpenBSD's acme-client is used, and runs under PASE.
It's a solid client, but requires editing a configuration file to use, and only
supports HTTP based challenges.

## Installation

* Install OpenSSL and acme-client from yum. Ensure you have the qsecofr repo.
* Run `make` from a PASE terminal (qp2term or SSH). This will automatically
  build the ILE portion.
* Run `make install` to install required PASE wrapper scripts.

## Usage

1. Edit your config file (`/QOpenSys/etc/acme-client.conf`) to add your domain.
  Remember the certificate and key files.
2. Ensure that the web server you use (Apache, nginx, etc) has the directory
  specified for the challenge directory is accessible. For example, using
  `/www/apachedft/htdocs/.well-known/acme-challenge` as the directory, make
  sure `/www/apachedft/htdocs/` is the root of your domain, so that the URL
  `http://domain.example.org/.well-known/acme-challenge` will be usable for
  the ACME server to query. (It's OK if it's in plain HTTP.)
3. Run `RNWACMCRT` to get the certificate. It will do any initialization if
  needed, and otherwise return completion `ACM0002` if renewal is unneeded.
4. Run `ADDDCMCRT` or `RNWDCMCRT` depending if you're adding the certificate
  for the first time or not.

Steps 3 and 4 can be automated with a scheduled job. (*XXX* provide one)

### Notes on security

Please make sure that the on-IFS certificates can only be read/changed by the
the user that the ACME client runs on, and that your DCM keystore is properly
secured. (Certificates can be allowed for the users that consuming applications
run as.) Failure to do so can result in malicious users impersonating your
system (et vice versa where malicious servers impersonate others to your
system) by stealing certificates and keys or injecting malicious certificates
into the DCM keystore.

## Notes on DCM keystores and IBM i APIs

DCM doesn't store certificates and keys as files in the IFS or as MI objects.
Instead, it uses an older GSK keystore format. This is a bit of an awkward
format to work with, and there are no GSK libraries on i, nor are there any
Java modules for them it seems. Instead, IBM i provides some APIs to manage
certificates. Unfortunately, these APIs are very limited in scope, certainly
not enough to manage certificates with. Not to mention some of these require
the very latest version, leak ugly implementation details, and are inconsistent
to use.

Instead, I've come up with something else. The DCM web UI (crufty as it may be)
includes a program that the Net.Data (bet you don't remember that) scripts call
to do the actual work with DCM. It has an undocumented and per-function calling
convention, but by looking at DCM's scripts, you can piece together enough to
figure out how to use them.

Unfortunately, this approach is pretty ugly. And has a tendency to occasional
make problem reports. (These can be mitigated if we do more validation; at
least as much as the web UI makes assumptions over.) But it *does* provide a
programmable way to manipulate DCM, and that's a good start.

We can use IBM i APIs when appropriate, of course.

Anyways, what does this mean for you? You'll have to provide the DCM keystore
file (`/QIBM/UserData/ICSS/Cert/Server/DEFAULT.KDB`, for `*SYSTEM`) and its
password when calling DCM related commands.

## TODOs and wishes

* We could handle base64/non-base64 better instead of assuming the former, when
  commands present themselves to allow it.
* More commands, more data validation.
* An ACME client that could operate directly on GSK keystores. It doesn't even
  need to be ILE. Also one that could support other challenges (alpn, dns, etc)
  and/or configuration from structured data to make scripts easier.

## Misc. links

* https://www.slideshare.net/OktawianPowazka/ibm-global-security-kit-as-a-cryptographic-layer-for-ibm-middleware
 * Information on GSK keystore format, in case of emergency
