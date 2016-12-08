# This class installs dependencies for Redhat Network mirroring. This
# primarily handles the specifics of preparing a CentOS host to connect to
# the RHN.
#
# == Parameters
#
# Optional parameters can be found in the mrepo::params class
#
# == Examples
#
# This class does not need to be directly included
#
# == Author
#
# Adrien Thebo <adrien@puppetlabs.com>
#
# == Copyright
#
# Copyright 2011 Puppet Labs, unless otherwise noted
#
class mrepo::rhn {

  include ::mrepo::params
  $group        = $mrepo::params::group
  $rhn          = $mrepo::params::rhn
  $rhn_config   = $mrepo::params::rhn_config
  $rhn_username = $mrepo::params::rhn_username
  $rhn_password = $mrepo::params::rhn_password

  if $rhn == true {

    package { 'pyOpenSSL':
      ensure  => present,
    }

    # CentOS does not have redhat network specific configuration files by default
    if $::operatingsystem == 'CentOS' or $rhn_config == true {

      # Added case statement to enable different RHN access for RHEL 7
      case $::operatingsystemmajrelease {
        '7': {
          exec { 'subscription-manager':
            command => "subscription-manager register --username ${rhn_username} --password ${rhn_password} --auto-attach",
            path    => ['/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
            unless  => 'subscription-manager status',
          }

          file { 'lftp.conf':
            ensure  => 'file',
            path    => '/etc/lftp.conf',
            content => template("${module_name}/lftp.conf.erb"),
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            require => Exec['subscription-manager'],
          }
      }
        default: {
          file {
            '/etc/sysconfig/rhn':
              ensure => directory,
              owner  => 'root',
              group  => 'root',
              mode   => '0755',
          }
          exec { 'Generate rhnuuid':
            command   => 'printf "rhnuuid=%s\n" `/usr/bin/uuidgen` >> /etc/sysconfig/rhn/up2date-uuid',
            path      => [ '/usr/bin', '/bin' ],
            user      => 'root',
            group     => $group,
            creates   => '/etc/sysconfig/rhn/up2date-uuid',
            logoutput => on_failure,
            require   => File['/etc/sysconfig/rhn'],
          }

          file { '/etc/sysconfig/rhn/up2date-uuid':
            ensure  => present,
            replace => false,
            owner   => 'root',
            group   => $group,
            mode    => '0640',
            require => Exec['Generate rhnuuid'],
          }

          file { '/etc/sysconfig/rhn/sources':
            ensure  => present,
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => 'up2date default',
          }

          file { '/usr/share/mrepo/rhn/RHNS-CA-CERT':
            ensure => present,
            owner  => 'root',
            group  => 'root',
            mode   => '0644',
            source => 'puppet:///modules/mrepo/RHNS-CA-CERT',
          }

          file { '/usr/share/rhn':
            ensure => directory,
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
          }

          file {'/usr/share/rhn/RHNS-CA-CERT':
            ensure => link,
            target => '/usr/share/mrepo/rhn/RHNS-CA-CERT',
          }
        }
      }
    }
  }
}
