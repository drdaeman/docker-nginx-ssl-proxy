Simple nginx-based SSL reverse proxy
====================================

A (yet another) dead-simple nginx-based SSL reverse proxy Docker image.

No auto-configuration, no ACME, no fancy stuff.
Just nginx configured to proxy to a single upstream.

Just because I haven't found this on Docker Hub.
Probably just haven't looked.

Usage
-----

    docker build -t nginx-ssl-proxy .

    docker run -it --rm -p 8443:443 \
        -e PROXY_PASS="http://example.org" \
        -e PROXY_HOST=example.org nginx-ssl-proxy

Variables
---------

The following environment variables map to nginx configuration settings:

  - `PROXY_PASS`
  - `SERVER_NAME` (defaults to `_`)
  - `SSL_CERTIFICATE` (a self-signed certificate generated if file does not exist)
  - `SSL_CERTIFICATE_KEY` (a new key is generated if file does not exist)
  - `CLIENT_BODY_BUFFER_SIZE`
  - `CLIENT_MAX_BODY_SIZE`
  - `PROXY_REDIRECT`
  - `PROXY_BUFFERING` (`off` by default)
  - `PROXY_CONNECT_TIMEOUT`
  - `PROXY_READ_TIMEOUT`
  - `PROXY_SEND_TIMEOUT`

Two variables that don't map to nginx settings:

  - `PROXY_HOST` - allows to override `proxy_set_header Host $host;`
  - `IPV6` - when set to `"yes"` (the default) listens on IPv6

Licensing
---------

I don't think this tiny piece of code is a copyrightable.
In case it is, see `UNLICENSE` file for details.
