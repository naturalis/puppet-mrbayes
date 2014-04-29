# == Class: mrbayes
#
# Full description of class mrbayes here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { mrbayes:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class mrbayes(
  $version          = '3.2.2',
  $exabayesversion  = '1.2.1',
  $packages         = ['build-essential','autoconf','openmpi-bin','libopenmpi-dev','libmpich2-dev','mpich2','subversion','libtool','pkg-config','openjdk-6-jdk'] 
)
{
  $downloadURL  = "http://sourceforge.net/projects/mrbayes/files/mrbayes/${version}/mrbayes-${version}.tar.gz/download"
  $downloadExabayesURL = "http://sco.h-its.org/exelixis/material/exabayes/${exabayesversion}/exabayes-${exabayesversion}-linux-openmpi-avx.tar.gz"
  
  package { $packages:
    ensure      => installed
  }

  exec { 'download_beagle':
    command     => "/usr/bin/svn checkout http://beagle-lib.googlecode.com/svn/trunk/ beagle-lib",
    cwd         => "/opt",
    unless      => "/usr/bin/test -d /opt/beagle-lib",
    require     => [Package[$packages]]
  }

  exec { 'configure_and_make_beagle':
    command     => '/opt/beagle-lib/autogen.sh && /opt/beagle-lib/configure --prefix=/usr/local && /usr/bin/make && /usr/bin/make install',
    cwd         => "/opt/beagle-lib",
    unless      => "/usr/bin/test -d /usr/local/include/libhmsbeagle-1",
    require     => Exec['download_beagle']
  }

  exec { 'download_mrbayes':
    command     => "/usr/bin/wget ${downloadURL} -O /opt/mrbayes-${version}.tar.gz",
    unless      => "/usr/bin/test -f /opt/mrbayes-${version}.tar.gz",
  }

  exec { 'unpack_mrbayes':
    command     => "/bin/tar -xzvf /opt/mrbayes-${version}.tar.gz -C /opt",
    unless      => "/usr/bin/test -d /opt/mrbayes_${version}",
    require     => Exec['download_mrbayes']
  }

  exec { 'compile_mrbayes':
    command     => "/usr/bin/autoconf && ./configure --enable-mpi=yes && /usr/bin/make && ldconfig",
    environment => ["LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH"],
    cwd         => "/opt/mrbayes_${version}/src",
    unless      => "/usr/bin/test -f /opt/mrbayes_${version}/src/mb",
    require     => [Package[$packages], Exec['configure_and_make_beagle']]
  }

  exec { 'download_exabayes':
    command     => "/usr/bin/wget ${downloadExabayesURL} -O /opt/exabayes-${exabayesversion}-linux-openmpi-avx.tar.gz",
    unless      => "/usr/bin/test -f /opt/exabayes-${exabayesversion}-linux-openmpi-avx.tar.gz",
  }

  exec { 'unpack_exabayes':
    command     => "/bin/tar -xzvf /opt/exabayes-${exabayesversion}-linux-openmpi-avx.tar.gz -C /opt",
    unless      => "/usr/bin/test -d /opt/exabayes-${exabayesversion}",
    require     => Exec['download_exabayes']
  }

  file { '/usr/bin/exabayes':
    ensure => 'link',
    target => "/opt/exabayes-${exabayesversion}/bin/bin/exabayes",
  }

  file { '/usr/bin/mb':
    ensure => 'link',
    target => "/opt/mrbayes_${version}/src/mb",
  }
}
