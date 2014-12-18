package { "git":                    ensure => "installed", require => Exec['apt-update'] }
package { "subversion":             ensure => "installed", require => Exec['apt-update'] }
package { "build-essential":        ensure => "installed", require => Exec['apt-update'] }
package { "default-jre":            ensure => "installed", require => Exec['apt-update'] }
package { "curl":                   ensure => "installed", require => Exec['apt-update'] }
package { "wget":                   ensure => "installed", require => Exec['apt-update'] }

exec { "apt-update":
    path => ["/bin", "/usr/bin"],
    command => "sudo apt-get update"
}

# SSH KEYS
file { "/home/vagrant/.ssh/id_rsa":
    ensure  => "present",
    mode    => 600,
    owner   => "vagrant",
    group   => "vagrant",
    replace => "yes",
    content => template('ssh/id_rsa.erb')
}

file { "/home/vagrant/.ssh/id_rsa.pub":
    ensure  => "present",
    mode    => 644,
    owner   => "vagrant",
    group   => "vagrant",
    replace => "yes",
    content => template('ssh/id_rsa.pub.erb')
}

exec { "download-jenkins":
    unless => 'ls /home/vagrant/jenkins.war',
    require => Package['wget'],
    path => ["/bin", "/usr/bin"],
    command => "wget https://updates.jenkins-ci.org/download/war/1.594/jenkins.war -O /home/vagrant/jenkins.war"
}

file { "/etc/rc.local":
    require => Exec['download-jenkins'],
    ensure  => "present",
    mode    => 755,
    owner   => "root",
    group   => "root",
    replace => "yes",
    content => template('boot/rc.local.erb')
}

exec { "rvm-key":
    path => ["/bin", "/usr/bin"],
    command => "gpg --keyserver hkp://pgp.mit.edu --recv-keys D39DC0E3"
}

exec { "install-rvm":
    unless => ['ls /home/vagrant/rvm'],
    require => Exec['rvm-key'],
    path => ["/bin", "/usr/bin"],
    command => 'su vagrant -c "curl -sSL https://github.com/wayneeseguin/rvm/tarball/stable -o /home/vagrant/rvm-stable.tar.gz && mkdir /home/vagrant/rvm && cd /home/vagrant/rvm && tar --strip-components=1 -xzf ../rvm-stable.tar.gz && ./install --auto-dotfiles --path ~"'
}

# exec { "install-jobs":
#     require => Exec['apt-update']
#     path => ["/bin", "/usr/bin"]
#     command => "cd /home/vagrant/.jenkins/jobs && git clone git@bitbucket.org:mrosati/h-art-ci.git ."
# }
