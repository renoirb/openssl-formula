# openssl

**NOT WORKING AT THE MOMENT**

Manage self-signed SSL certificates and file permissions.

This formula allows to provide your Certificate Authority certificate and key files
spreaded using pillars.


## note:

    See the full `Salt Formulas installation and usage instructions
    <http://docs.saltstack.com/topics/conventions/formulas.html>`_.


## Available states

* `openssl.certificate` (macro) -- Ensure existence of a certificate or generate one based on provided CA certificates.


## Usage sample:

To create a certificate in `/etc/ssl/private/server-cert.pem` owned by user `mysql` and group `nobody`.

    import:
      - openssl

    {% from "openssl/certificate.sls" import certificate %}

    {{ certificate('/etc/ssl/private/', 'server', 'mysql', 'nobody', '/etc/ssl/private/ca-cert.pem', '/etc/ssl/private/ca-key.pem') }}



## CA certificates

### Create your own

On a server that has openssl installed, run:

```bash
openssl genrsa 2048 > ca-key.pem
openssl req -new -x509 -nodes -days 3600 -key ca-key.pem -out ca-cert.pem
``

### Install your CA certificates in your own pillar

Copy contents with appropriate YML indentation in your pillar file:

e.g.:

```
openssl:
  shared:
    ca-cert.pem: |
      -----BEGIN CERTIFICATE-----
      YOUR CERTIFICATE KEY
      -----END CERTIFICATE-----
    ca-key.pem: |
      -----BEGIN RSA PRIVATE KEY-----
      YOUR CERTIFICATE KEY
      -----END RSA PRIVATE KEY-----
``
