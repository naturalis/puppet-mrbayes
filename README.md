puppet-mrbayes
===================

Puppet modules for deployment of mrbayes and exabayes with multicore support

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
  $exabayesversion  = '1.2.1',
  $packages         = ['build-essential','autoconf','openmpi-bin','libopenmpi-dev','libmpich2-dev','mpich2','subversion','libtool','pkg-config','openjdk-6-jdk'] 

```
Result
-------------
mrbayes binary with mpi support, using beagle.
Binary, compiled from source mb in /opt/mrbayes_<version>/src with symlink in /usr/bin
Beagle libraries in /opt/beagle-lib compiled and installed in /usr/local/includes

exabayes binaries are straight from source tar archive. Symlink is created to the exabayes binary 
source and support files in /opt/exabayes-1.2.1, all binaries in /opt/exabayes-1.2.1/bin/bin

Usage example mrbayes with hymfossil.nex demo file:
```
mpirun -np 8 mb /opt/mrbayes_3.2.2/examples/hymfossil.nex > ~/log.txt
```
results of run can be found in ~/log.txt

Usage example exabayes with example dataset file:
```
cd /opt/exabayes-1.2.1/examples/aa
mpirun -np 8 exabayes -f aln.phy -m PROT -c config.nex -n myRun -s 123 -M 3 -S

```

Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.

The module has been tested on:
- Ubuntu 12.04LTS


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>

