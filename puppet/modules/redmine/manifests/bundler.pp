class redmine::bundler inherits params {

  exec { 'Bundler Install':
    path          => ['/usr/local/bin/', '/bin/'],
    command       => 'sudo bundler install --without development test mysql sqlite',
    cwd           => "${redmine_dir_path}/${redmine_directory}",
    user          => 'redmine',
    environment   => 'HOME=/home/redmine',
  }
}
