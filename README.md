# Ravenports
Universal package builder system

## Objective

To develop the next generation software collection builder and packager
that is also truly cross-platform.  Think FreeBSD ports with several new
cutting edge features and enhancements, but with equal support to Linux,
Solaris(like), MacOS, and all BSD platforms.

It is not a reinvention of pkgsrc.  The approach is new and not based
on make.

## Ravenports Triad

There are three main components of Ravenports.

  1. **Source ports:**
This component, known as "ravensource" is not seen or utilized by
regular users.  It resembles
the ports tree seen in FreeBSD and pkgsrc, but only at the individual
port directory level.  It is not arranged in categories.  The contents
of each port directory is used to generate a port buildsheet.

  2. **Conspiracy:**
The conspiracy repository contains all the buildsheets, separated into
256 bucket directories.  These single files are the complete recipe for
building the software for which they were created.  These buildsheets
are not meant to be viewed directly, as their information can be queried
by the ravenadm tool.  The conspiracy buildsheets are "compiled" from
ravensource and getting the latest ports is accomplished by updating the
repository.  This README is contained within the Conspiracy repository.

  3. **Raven administration tool:**
The administration tool for Ravenports is "ravenadm".  It can query the
ports for many types of information like a database.  It can build
packages in parallel (think synth interface).  It controls the build
environment such that it is the same across users, even if those
users are on different operating systems.  Raven also plays a part
in the development of ports and features inbuilt lint, sanity checks
and compile checks.  If somebody develops a buildsheet that passes
all checks and builds, it likely can be incorporated in the source
tree as submitted, especially if the submission process includes
automated testing on all supported platforms.

## Make has really been eliminated?

Actually, not really.  Make is pretty good at the actual building of the
port.  A significant chunk of FreeBSD's build logic will be retained
(although improved upon).  Raven will generate a makefile dynamically
depending on options and variants requested for the purpose of
building and packaging the software.  The logic will be straight-forward
without recursion or shell forking.  Keeping this logic at
${RAVENBASE}/share/mk will ensure adaptability.

The options handling and other complex logic that affect package
dependencies will be done by the ravenadm internally.  This will
enable speedups by magnitudes as compared to other ports systems.

## Official Website

Please visit
[http://www.ravenports.com](http://www.ravenports.com)
for additional and current information.

## License

The contents of this repository are available under the
conditions defined by the Internet Systems Consortium (ISC) license:

---

```
Copyright (c) 2017-2021, The Ravenports Project.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

## SHA256 digests for Ravenports bootstrap files

Currently the repositories are only available via HTTP.  The SHA256 digests
are listed before for confidence the bootstrap ravensw(8) binaries are the ones
we generated.

```
e28fde00276880da2183439eb1e45c962147f90aca5482b9ac2df1a28dfd011a raven-darwin-bootstrap.tar.gz
957b12522aa1e73173c98dca0e5fab9fba7961da149a02b63925bcaf7310de85 ravensw-dragonfly-58-bootstrap.tar.gz
6ace12f1b1e2ceebb4bb0efcf1016a22f72cd24ca35c248234a71ef05dfa5b3d ravensw-freebsd64-bootstrap.tar.gz
3c7090bc98eb8def52328b94096581ec9c7bea78c8e8676fb532dc0695041a00 ravensw-linux-bootstrap.tar.gz
3b37a88000b2156d137a44d684abfcdc646f1f34fa87410af3167c8614e3b41d ravensw-sunos-bootstrap.tar.gz
```

## Ravenports public key

All Ravenports repositories are signed by the following key.

```
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA4rhIOkp+aJS04AOz/V0S
gKOg7Ol/rUTUeHUwzbE45vvGq+M7s00MKDhzdU6QBPnhRLaPdRf8jJNCcNIEIjQ4
fON43BNJfJX1q5T1jnT4Dd+pyyejPv3gOQdDARYt4risfeey3BBYQMuOghGoCNDt
DYPsWaBUPHUR+Um96U0CYHl3ZeAbovq466Wn3OuYX3gvg4QPaMPKmx1fgI3V9bDA
KuOBD5JEVzhJgtzv33e7C0murs4WWJpRv3eSinZsUKoFbt4F4To+YrIXnOQPrNdr
u25Z5hSBdNT5gM43JKWWqM57Zi60Poj5nG6p+GxGePWrraOQY68mgDEScTrJLIXj
UwIDAQAB
-----END PUBLIC KEY-----
```

An example of use is to save the contents to
/raven/etc/ravensw/keys/ravenports.key.  The ravensw repository
configuration file might look like this:

```
> cat /raven/etc/ravensw/repos/01_raven.conf
Raven: {
    url            : http://www.ravenports.com/repository/${ABI},
    pubkey         : /raven/etc/ravensw/keys/ravenports.key,
    signature_type : PUBKEY,
    priority       : 0,
    enabled        : yes
}
```
