class fuel-plugin-ceph_multibackend::osd_id {

 Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }
 $node_volumes = hiera('node_volumes', [])
 $dev = get_target_disk($node_volumes, 'ceph-backend2')
 $plugin_settings = hiera('fuel-plugin-ceph_multibackend')
 $file_osd_id_exists = inline_template("<% if File.exist?('/var/log/lost+found/osd_create.lock') -%>true<% end -%>")
 $node_name=hiera(node_name)
 
 define crush_osd {

  $osd_id = get_osd_id($name)
  $node_name=hiera(node_name)

  exec { "Removing ssd $name osd from host HDD bucket":
                 command => "ceph osd crush remove osd.$osd_id $node_name.HDD",
  }
  ->
  exec { "Adding ssd $name item to SSD bucket":
                 command => "ceph osd crush add osd.$osd_id 1.0 host=$node_name.SSD",
  }
 }

if $file_osd_id_exists == ''
 {
 exec { "Creating new SSD bucket":
                 command => "ceph osd crush add-bucket $node_name.SSD host",
  }
  ->
  exec { "Renaming old bucket":
                 command => "ceph osd crush rename-bucket $node_name $node_name.HDD",
  }
  ->
  exec { "Adding ssd host to SSD region":
                 command => "ceph osd crush move $node_name.SSD region=SSD",
  }
  ->
  exec { "Adding HDD host to HDD region":
                 command => "ceph osd crush move $node_name.HDD region=HDD",
  }
  ->
  crush_osd { $dev : }
  ->
  file {"/var/log/lost+found":
           ensure => 'directory',
  }
  ->
  file {"/var/log/lost+found/osd_create.lock":
           ensure => 'file',
           path => "/var/log/lost+found/osd_create.lock",
  }

 }

}
