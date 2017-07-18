class fuel-plugin-ceph_multibackend::regions {

 Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
 $plugin_settings = hiera('fuel-plugin-ceph_multibackend')

  exec { "creating SSD region":
                 command => "ceph osd crush add-bucket SSD region",
  }->
  exec { "creating HDD region":
                 command => "ceph osd crush add-bucket HDD region",
  }
  file {"/var/log/lost+found":
         ensure => 'directory',
  }

}
