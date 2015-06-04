# == Class: mrbayes
#
#
class mrbayes(
  $version          = '3.2.5',
  $exabayesversion  = '1.4.1',
  $packages         = ['build-essential','autoconf','openmpi-bin','libopenmpi-dev','libmpich2-dev','mpich2','subversion','libtool','pkg-config','openjdk-6-jdk'] 
)
{

# Set download locations
  $downloadURL  = "http://sourceforge.net/projects/mrbayes/files/mrbayes/${version}/mrbayes-${version}.tar.gz/download"
  $downloadExabayesURL = "http://sco.h-its.org/exelixis/material/exabayes/${exabayesversion}/exabayes-${exabayesversion}-linux-openmpi-avx.tar.gz"

# Install all packages
  package { $packages:
    ensure      => installed
  }

# Download beagle from subversion repo
  exec { 'download_beagle':
    command     => '/usr/bin/svn checkout http://beagle-lib.googlecode.com/svn/trunk/ beagle-lib',
    cwd         => '/opt',
    unless      => '/usr/bin/test -d /opt/beagle-lib',
    require     => [Package[$packages]]
  }

# configure and make beagle
  exec { 'configure_and_make_beagle':
    command     => '/opt/beagle-lib/autogen.sh && /opt/beagle-lib/configure --prefix=/usr/local && /usr/bin/make && /usr/bin/make install',
    cwd         => '/opt/beagle-lib',
    unless      => '/usr/bin/test -d /usr/local/include/libhmsbeagle-1',
    require     => Exec['download_beagle']
  }

# Download mrbayes source files
  exec { 'download_mrbayes':
    command     => "/usr/bin/wget ${downloadURL} -O /opt/mrbayes-${version}.tar.gz",
    unless      => "/usr/bin/test -f /opt/mrbayes-${version}.tar.gz",
  }

# Unpack mrbayes source files
  exec { 'unpack_mrbayes':
    command     => "/bin/tar -xzvf /opt/mrbayes-${version}.tar.gz -C /opt/",
    unless      => "/usr/bin/test -d /opt/mrbayes_${version}",
    require     => Exec['download_mrbayes']
  }

# Compile mrbayes
  exec { 'compile_mrbayes':
    command     => '/usr/bin/autoconf && ./configure --enable-mpi=yes && /usr/bin/make && ldconfig',
    environment => ["LD_LIBRARY_PATH=$HOME/lib:$LD_LIBRARY_PATH"],
    cwd         => "/opt/mrbayes_${version}/src",
    unless      => "/usr/bin/test -f /opt/mrbayes_${version}/src/mb",
    require     => [Package[$packages], Exec['configure_and_make_beagle']]
  }

# Download exabayes
  exec { 'download_exabayes':
    command     => "/usr/bin/wget ${downloadExabayesURL} -O /opt/exabayes-${exabayesversion}-linux-openmpi-avx.tar.gz",
    unless      => "/usr/bin/test -f /opt/exabayes-${exabayesversion}-linux-openmpi-avx.tar.gz",
  }

# Unpack exabayes
  exec { 'unpack_exabayes':
    command     => "/bin/tar -xzvf /opt/exabayes-${exabayesversion}-linux-openmpi-avx.tar.gz -C /opt",
    unless      => "/usr/bin/test -d /opt/exabayes-${exabayesversion}",
    require     => Exec['download_exabayes']
  }

# create link to exabayes binary
  file { '/usr/bin/exabayes':
    ensure => 'link',
    target => "/opt/exabayes-${exabayesversion}/bin/bin/exabayes",
  }

# fix libmpi libraries for exabayes 1 of 2
  file { '/usr/lib/libmpi_cxx.so.0':
    ensure => 'link',
    target => '/usr/lib/libmpi_cxx.so.1',
  }

# fix libmpi libraries for exabayes 2 of 2
  file { '/usr/lib/libmpi.so.0':
    ensure => 'link',
    target => '/usr/lib/libmpi.so.1',
  }

# create link to mrbayes binary
  file { '/usr/bin/mb':
    ensure => 'link',
    target => "/opt/mrbayes_${version}/src/mb",
  }
}