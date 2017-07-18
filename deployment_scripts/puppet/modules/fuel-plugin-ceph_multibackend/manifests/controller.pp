class fuel-plugin-ceph_multibackend::controller {

 include ::glance::params
 include ::cinder::params
 $plugin_settings = hiera('fuel-plugin-ceph_multibackend')
 $ssd_pool=$plugin_settings['ceph_pool']
 glance_api_config {
         "glance_store/rbd_store_pool": value => "$ssd_pool";
}
 Glance_api_config<||> ~> Service['glance-api']

 service { 'glance-api':
    ensure  => 'running',
    enable  => true,
  }


 file_line{"RBD-fast backend":
   ensure => present,
   path   => "/etc/cinder/cinder.conf",
   line   => "[RBD-fast]",
 }
 ->
 file_line {"enable second volume backend":
   path  => "/etc/cinder/cinder.conf",
   match => "^enabled_backends = RBD-backend$",
   line  => "enabled_backends = RBD-backend, RBD-fast",
 }
 ->
 cinder_config {
   "RBD-fast/volume_backend_name":      value => "RBD-fast";
   "RBD-fast/rbd_pool":                 value => "$ssd_pool";
   "RBD-fast/rbd_user":                 value => "volumes";
   "RBD-fast/rbd_secret_uuid":          value => "$rbd_secret";
   "RBD-fast/backend_host":             value => "rbd:volumes";
   "RBD-fast/volume_driver":            value => "cinder.volume.drivers.rbd.RBDDriver";
   "RBD-fast/rbd_ceph_conf":            value => "/etc/ceph/ceph.conf";
   "RBD-backend/rbd_pool":              value => "volumes";
 }

 Cinder_config<||> ~> Service['cinder-volume']
 Cinder_config<||> ~> Service['cinder-scheduler']
 service { 'cinder-volume':
    ensure  => 'running',
    enable  => true,
  }
 service { 'cinder-scheduler':
    ensure  => 'running',
    enable  => true,
  }

}
