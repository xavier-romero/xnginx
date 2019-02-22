# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include xnginx
class xnginx ( $fqdn = 'domain.com', $certdir = '/etc/ssl/certs')
{
        package {'nginx':
			ensure => installed,
		}

		exec {'create_self_signed_sslcert':
			command => "openssl req -newkey rsa:2048 -nodes -keyout ${fqdn}.key  -x509 -days 365 -out ${fqdn}.crt -subj '/CN=${fqdn}'",
			cwd     => $certdir,
			creates => [ "${certdir}/${fqdn}.key", "${certdir}/${fqdn}.crt", ],
			path    => ["/usr/bin", "/usr/sbin"]
        }

        exec {'create_dhparam':
                command => "openssl dhparam -out ${certdir}/dhparam.pem 2048",
                cwd     => $certdir,
                creates => "${certdir}/dhparam.pem",
                path    => ["/usr/bin", "/usr/sbin"]
        }

		service {'nginx':
			require => [ Package['nginx'], Exec['create_self_signed_sslcert'], Exec['create_dhparam'] ],
			ensure => running,
		}

}

define xnginx::test1 ($proxies = [])
{

	if ! defined(Class['xnginx']) {
    	fail('You must include the xnginx base class before using any defined resources')
	}
  
		file {'/etc/nginx/conf.d/test1.conf':
			ensure => file,
			require => Package['nginx'],
			content => template('xnginx/test1.conf.erb'),
			#source => "puppet:///modules/xnginx/test1.conf",
			notify  => Service['nginx'],
		}
}

define xnginx::test2 ($proxyport = 8080, $localnetworks = ['192.168.0.0/24', '172.16.0.0/12', '10.0.0.0/8'])
{

	if ! defined(Class['xnginx']) {
    	fail('You must include the xnginx base class before using any defined resources')
	}
  
		file {'/etc/nginx/conf.d/test2.conf':
			ensure => file,
			require => Package['nginx'],
			content => template('xnginx/test2.conf.erb'),
			notify  => Service['nginx'],
		}
}
