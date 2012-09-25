class nagios::irc_bot {
  if ( ! ($nsa_server and $nsa_nickname and $nsa_channel) ) {
    fail("Please provide values at least for \$nsa_server, \$nsa_nickname and \$nsa_channel")
  }

  case $operatingsystem {
    centos: {
      $nsa_default_socket = '/var/run/nagios-nsa/nsa.socket'
      $nsa_default_pidfile = '/var/run/nagios-nsa/nsa.pid'
      include nagios::irc_bot::centos
    }
    default: {
      $nsa_default_socket = '/var/run/nagios3/nsa.socket'
      $nsa_default_pidfile = '/var/run/nagios3/nsa.pid'
      include nagios::irc_bot::base
    }
  }

  if $nagios::manage_shorewall {
    include shorewall::rules::out::irc
  }
}
