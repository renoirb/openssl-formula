{% macro certificate(wherePath, certName, user, group, certificateAuthorityFile, certificateAuthorityKeyFile) -%}

{% set reqFile  = wherePath ~ certName ~ '-req.pem' %}
{% set certFile = wherePath ~ certName ~ '-cert.pem' %}
{% set keyFile  = wherePath ~ certName ~ '-key.pem' %}

{% set days  = salt['pillar.get']('openssl:certificate:days',  3600) %}
{% set C  = salt['pillar.get']('openssl:subject:Country',      'US') %}
{% set ST = salt['pillar.get']('openssl:subject:State',        'Utah') %}
{% set L  = salt['pillar.get']('openssl:subject:City',         'Salt Lake City') %}
{% set O  = salt['pillar.get']('openssl:subject:Organization', 'OpenStack') %}
{% set OU = salt['pillar.get']('openssl:subject:Unit',         'Not specified') %}
{% set E  = salt['pillar.get']('openssl:subject:Email',        'xyz@pdq.net') %}

{% set subject = ' -subj "/C=' ~ C ~ '/ST=' ~ ST ~ '/L=' ~ L ~ '/O=' ~ O ~ '/OU=' ~ OU ~ '/CN=' ~ canonicalName ~ '/emailAddress=' ~ E ~ '"' %}

check-owner:
  user:
    - present
    - name: {{ user }}

group:
  group:
    - present
    - name: {{ group }}

openssl-ca-file:
  file:
    - exists
    - name: {{ certificateAuthorityFile }}

openssl-ca-key-file:
  file:
    - exists
    - name: {{ certificateAuthorityKeyFile }}

openssl-{{ certName }}-req:
  cmd.run:
    - stateful: True
    - unless: test -s {{ reqFile }}
    - name: openssl req -newkey rsa:2048 -days {{ days }} -nodes -keyout {{ keyFile }} -out {{ reqFile }}{{ subject }}
    - require:
      - pkg: openssl
  file.managed:
    - name: {{ reqFile }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - require:
      - user: check-owner
      - group: check-group

{{ certFile }}:
  cmd.run:
    - stateful: True
    - name: openssl x509 -req -in {{ reqFile }} -days {{ days }} -CA {{ certificateAuthorityFile }} -CAkey {{ certificateAuthorityKeyFile }} -set_serial 01 -out {{ certFile }}
    - unless: test -s {{ certFile }}
    - require:
      - cmd: openssl-{{ certName }}-req
      - file: openssl-ca-key-file
      - file: openssl-ca-file
  file.managed:
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - require:
      - user: check-owner
      - group: check-group

{{ keyFile }}:
  cmd.run:
    - stateful: True
    - name: openssl rsa -in {{ keyFile }} -out {{ keyFile }}
    - require:
      - cmd: openssl-{{ certName }}-req
  file.managed:
    - user: {{ user }}
    - group: {{ group }}
    - mode: 640
    - require:
      - user: check-owner
      - group: check-group
{% endmacro %}