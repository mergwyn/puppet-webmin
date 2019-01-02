class webmin::repo () inherits webmin {

  assert_private("Use of private class ${name} by ${caller_module_name}")

  $release = $::facts[operatingsystemrelease]

  if $webmin::repo_manage {
    case $::facts[os][family] {
      'RedHat': {
        yumrepo { 'epel':
          ensure   => $webmin::repo_ensure,
          baseurl  => lookup('webmin::package_epel_url'),
          enabled  => true,
          gpgcheck => true,
          gpgkey   => lookup('webmin::package_epel_key'),
          descr    => 'EPEL Distribution',
        }
        yumrepo { 'webmin':
          ensure     => $webmin::repo_ensure,
          mirrorlist => 'http://download.webmin.com/download/yum/mirrorlist',
          enabled    => true,
          gpgcheck   => true,
          gpgkey     => 'http://www.webmin.com/jcameron-key.asc',
          descr      => 'Webmin Distribution',
        }
      }
      'Debian': {
        require apt

        notify {"Setting up system as test VM: ${::facts[test_vm]}":}
        if $::facts[test_vm] {
          anchor { "${module_name}::begin_update": }
          -> class { "${module_name}::update::ppa": }
          -> class { "${module_name}::update::sources": }
          -> class { "${module_name}::update::apt": }
          -> anchor { "${module_name}::end_update": }
        } else {
          anchor { "${module_name}::begin_update": }
          -> class { "${module_name}::update::sources": }
          -> class { "${module_name}::update::apt": }
          -> anchor { "${module_name}::end_update": }
        }
      }
      'Archlinux': {}
      default: {}
    }
  }
}
