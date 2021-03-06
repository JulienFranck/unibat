# -*- mode: ruby -*-
# vi: set ft=ruby :

node 'unitex.fqdn.org' {
  $one_day = 86400 # Une journée en secondes

  Exec {
    path    => ['/bin', '/usr/bin', '/usr/sbin'],
  }

  # Nobody is perfect
  package { 'language-pack-fr': 
    ensure => present,
  }
  exec { 'locale-gen':
    command => 'locale-gen --lang fr_FR.UTF-8',
    require => Package['language-pack-fr'],
    unless  => 'grep -q fr_FR.UTF-8 /var/lib/locales/supported.d/local' 
  }
  exec { 'set-timezone':
    command => 'timedatectl set-timezone Europe/Paris',
    require => Exec['locale-gen'],
    unless  => 'timedatectl status|grep -q Europe/Paris'
  }

  # Installation des paquets nécessaires sur le host Docker
  # NB: c'est Vagrant qui installe Docker (cf provisionning dans Vagrantfile)
  package { ['unzip','curl','htop','p7zip-full','liburi-perl']: 
    ensure => present, 
    require => Exec['set-timezone']
  }

  # Script de lancement d'un unitex dockérisé
  file { '/home/vagrant/unitex.sh':
    source  => 'puppet:///modules/files/unitex.sh',
    owner   => 'vagrant',
    group   => 'vagrant',
    mode    => '0755'
  }
}
