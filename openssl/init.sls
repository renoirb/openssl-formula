openssl:
  pkg:
    - installed

/etc/ssl/private/ca-key.pem:
  file.managed:
    - user: mysql
    - group: mysql
    - mode: 640
    - contents_pillar: 'openssl:shared:ca-key.pem'

/etc/ssl/private/ca-cert.pem:
  file.managed:
    - user: mysql
    - group: mysql
    - mode: 640
    - contents_pillar: 'openssl:shared:ca-cert.pem'