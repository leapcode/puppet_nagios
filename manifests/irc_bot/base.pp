class nagios::irc_bot::base {

    # Default values for the two first variables are defined in nagios::irc_bot
    $nsa_socket = $nsa_socket ? {
        '' => $nsa_default_socket,
        default => $nsa_socket,
    }
    $nsa_pidfile = $nsa_pidfile ? {
        '' => $nsa_default_pidfile,
        default => $nsa_pidfile,
    }
    $nsa_port = $nsa_port ? {
        '' => '6667',
        default => $nsa_port,
    }
    $nsa_realname = $nsa_realname ? {
        '' => 'Nagios',
        default => $nsa_realname,
    }

    if (! $nsa_password) {
        $nsa_password = ''
    }

    if (! $nsa_usenotices) {
      $nsa_usenotices = ''
    }
    
    file { "/usr/local/bin/riseup-nagios-client.pl":
        owner => root, group => 0, mode => 0755,
        source => "puppet:///modules/nagios/irc_bot/riseup-nagios-client.pl",
    }
    file { "/usr/local/bin/riseup-nagios-server.pl":
        owner => root, group => 0, mode => 0755,
        source => "puppet:///modules/nagios/irc_bot/riseup-nagios-server.pl",
    }
    file { "/etc/init.d/nagios-nsa":
        owner => root, group => 0, mode => 0755,
        content => template("nagios/irc_bot/${operatingsystem}/nagios-nsa.sh.erb"),
        require => File["/usr/local/bin/riseup-nagios-server.pl"],
    }
    file { "/etc/nagios_nsa.cfg":
        ensure => present,
        owner => nagios, group => 0, mode => 0400,
        content => template('nagios/irc_bot/nsa.cfg.erb'),
        notify => Service["nagios-nsa"],
    }

    package { "libnet-irc-perl":
        ensure => present,
    }

    service { "nagios-nsa":
        ensure => "running",
        hasstatus => true,
        enable => true,
        require => [File["/etc/nagios_nsa.cfg"],
                    File["/etc/init.d/nagios-nsa"],
                    Package["libnet-irc-perl"],
                    Service['nagios'] ],
    }

    nagios_command {
        "notify-by-irc":
            command_line => '/usr/local/bin/riseup-nagios-client.pl "$HOSTNAME$ ($SERVICEDESC$) $NOTIFICATIONTYPE$ $SERVICEATTEMPT$/$MAXSERVICEATTEMPTS$ $SERVICESTATETYPE$ $SERVICEEXECUTIONTIME$s $SERVICELATENCY$s $SERVICEOUTPUT$ $SERVICEPERFDATA$"';
        "host-notify-by-irc":
            command_line => '/usr/local/bin/riseup-nagios-client.pl "$HOSTNAME$ ($HOSTALIAS$) $NOTIFICATIONTYPE$ $HOSTATTEMPT$/$MAXHOSTATTEMPTS$ $HOSTSTATETYPE$ took $HOSTEXECUTIONTIME$s $HOSTOUTPUT$ $HOSTPERFDATA$ $HOSTLATENCY$s"';
    }
}
