class sensu::gems inherits sensu {

  package { $gempackages:
    ensure    => installed,
    provider  => 'gem',
  }
}
