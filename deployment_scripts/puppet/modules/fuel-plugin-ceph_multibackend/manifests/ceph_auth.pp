class fuel-plugin-ceph_multibackend::ceph_auth {

 $plugin_settings = hiera('fuel-plugin-ceph_multibackend')
 $ssd_pool=$plugin_settings['ceph_pool']
 Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }

 #image_rbd_pool and volume_rbd_pool from facter, in case of fuel > 9.0
 if $image_rbd_pool == '0' {
   exec { "Update auth caps for ssd pool":
                command => "ceph auth caps client.images osd \"allow class-read object_prefix rbd_children, allow rwx pool=$ssd_pool\" mon \"allow r\"",
        }
 }
 if $volume_rbd_pool == '0' {
   exec { "Update auth caps for volumes client":
                command => "ceph auth caps client.volumes osd \"allow class-read object_prefix rbd_children, allow rwx pool=$ssd_pool, allow rwx pool=volumes, allow rwx pool=images, allow rwx pool=compute\" mon \"allow r\"",
        }
 }
 
 exec { "Update auth caps for compute client":
                command => "ceph auth caps client.compute osd \"allow class-read object_prefix rbd_children, allow rwx pool=$ssd_pool, allow rwx pool=volumes, allow rwx pool=images, allow rwx pool=compute\" mon \"allow r\"",
 }
 
}
