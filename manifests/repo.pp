class webmin::repo () inherits webmin {

  assert_private("Use of private class ${name} by ${caller_module_name}")

  $release = $::facts[operatingsystemrelease]

  if $webmin::repo_manage {
    case $::facts[os][name] {
      'CentOS': {
        yumrepo { 'epel':
          ensure   => $webmin::repo_ensure,
          baseurl  => $webmin::params::package_epel_url,
          enabled  => true,
          gpgcheck => true,
          gpgkey   => $webmin::params::package_epel_key,
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
      'Debian', 'Ubuntu': {
        require apt

        class { 'webmin::update::ppa':
        }
        -> apt::source { 'webmin_mirror':
          ensure   => 'absent',
          location => 'http://webmin.mirror.somersettechsolutions.co.uk/repository',
          release  => 'sarge',
          repos    => 'contrib',
          key      => {
            'id'     => '1719003ACE3E5A41E2DE70DFD97A3AE911F63C51',
            'source' => 'http://www.webmin.com/jcameron-key.asc',
          },
          include  => {
            'src' => false,
          },
        }
        -> apt::source { 'webmin_main':
          ensure   => $webmin::params::repo_ensure,
          location => 'http://download.webmin.com/download/repository',
          release  => 'sarge',
          repos    => 'contrib',
          key      => {
            'id'     => '1719003ACE3E5A41E2DE70DFD97A3AE911F63C51',
            'source' => 'http://www.webmin.com/jcameron-key.asc',
          },
          include  => {
            'src' => false,
          },
        }
        -> class { 'webmin::update::apt': }
      }
      'Archlinux': {}
      default: {}
    }
  }
}
