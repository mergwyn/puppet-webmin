class webmin::params {
  $repo_ensure     = present
  $repo_manage     = true
  $package_manage  = true
  $package_ensure  = 'latest'
  $package_name    = 'webmin'
  $ssl_dependencies= $facts[os][family] ? {
    'RedHat'    => ['perl-Net-SSLeay', 'perl-Encode-Detect', 'perl-Authen-PAM'],
    'Debian'    => ['perl', 'libnet-ssleay-perl', 'openssl', 'libauthen-pam-perl', 'libpam-runtime', 'libio-pty-perl', 'apt-show-versions', 'python'],
    'Archlinux' => ['perl-net-ssleay'],
    default     => [],
  }
  $config_file     = '/etc/webmin/miniserv.conf'
  $service_enable  = true
  $service_ensure  = 'running'
  $service_manage  = true
  $service_name    = 'webmin'
  $allowed_networks= []
  $firewall_manage = false

  $service_port    = 10000
  $ssl_enable      = true
  $ssl_keyfile     = '/etc/webmin/miniserv.pem'
  $ssl_certfile    = '/etc/webmin/miniserv.cert'
  $ssl_chainfile   = '/etc/webmin/extracas.chain'
  $ssl_reject_ssl2 = true
  $ssl_reject_ssl3 = true
  $ssl_reject_tls1 = true
  $ssl_reject_tls11= true
  $ssl_reject_tls12= false
  $ssl_redirect    = true

  $package_epel_url = $::facts[os][family] ? {
    'RedHat' => "https://dl.fedoraproject.org/pub/epel/${::facts[os][release][major]}/${::facts[os][architecture]}/",
    default => '',
  }

  $package_epel_key = $::facts[os][family] ? {
    'RedHat' => $::facts[os][release][major] ? {
      '6' => 'https://getfedora.org/static/0608B895.txt',
      '7' => 'https://getfedora.org/static/352C64E5.txt',
      default => '',
    },
    default => '',
  }
}
