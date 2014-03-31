puppet-mrbayes
===================

Puppet modules for deployment of mrbayes with multicore support 

Parameters
-------------
All parameters are set as defaults in init.pp or can be overwritten using the Foreman

Classes
-------------
- mrbayes

Dependencies
-------------
- no module dependencies.


Parameters
-------------
Version and packages, defaults to the packages needed for compiling from source.


```
  $version          = '3.2.2',
  $packages         = ['build-essential','autoconf','libmpich2-dev','mpich2','subversion','libtool','pkg-config','openjdk-6-jdk'] 

```
Puppet code
```
class { bioportal: }
```
Result
-------------
mrbayes binary with mpi support, using beagle.
Binary, compiled from source mb in /opt/mrbayes_<version>/src with symlink in /usr/bin
Beagle libraries in /opt/beagle-lib compiled and installed in /usr/local/includes


Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.

The module has been tested on:
- Ubuntu 12.04LTS


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>

