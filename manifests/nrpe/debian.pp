class nagios::nrpe::debian inherits nagios::nrpe::base {
  Service['nagios-nrpe-server'] {
    hasstatus => false,
  }
}
