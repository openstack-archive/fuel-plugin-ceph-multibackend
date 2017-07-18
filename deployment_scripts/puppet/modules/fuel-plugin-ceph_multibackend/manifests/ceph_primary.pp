class fuel-plugin-ceph_multibackend::ceph_primary {
 include ::cinder::params
 Exec { path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' }

 $access_hash = hiera(access)
 $pass = $access_hash['password']
 $user = $access_hash['user']
 $tenant = $access_hash['tenant']
 $service_endpoint = hiera(service_endpoint)
 $management_vip = hiera(management_vip)
 $auth_uri = "http://$service_endpoint:5000/"
 $plugin_settings = hiera('fuel-plugin-ceph_multibackend')
 $ssd_pool=$plugin_settings['ceph_pool']
 $ssd_pg_num = $plugin_settings['ceph_ssd_pg_num']
 $HDD_pg_num = $plugin_settings['ceph_HDD_pg_num']
 $file_ma_crush_new_map_exists = inline_template("<% if File.exist?('/var/log/lost+found/ma-crush-new-map') -%>true<% end -%>")
 $file_cinder_type_lock_exists = inline_template("<% if File.exist?('/var/log/lost+found/cinder_ceph_type.lock') -%>true<% end -%>")

if $management_vip == $service_endpoint { #in case of local keystone
$region='RegionOne'
}
else { #in case of detach keystone
$region=hiera(region)
}

if $file_ma_crush_new_map_exists == ''
{
  exec { "add HDD region to root":
        command => "ceph osd crush move HDD root=default",
  }
->
  exec { "add SSD region to root":
        command => "ceph osd crush move SSD root=default",
  }
->
  exec { "Get Crushmap":
        command => "ceph osd getcrushmap -o /var/log/lost+found/ma-crush-map",
       }
->
  exec { "Decompile crushmap":
            command => "crushtool -d /var/log/lost+found/ma-crush-map -o /var/log/lost+found/ma-crush-map.txt"
  }
->
  file_line { "Adding ssd rule":
               path => "/var/log/lost+found/ma-crush-map.txt",
               line => "rule ssd {\n        ruleset 255\n        type replicated\n        min_size 1\n        max_size 10\n        step take SSD\n        step choose firstn 0 type osd\n        step emit\n}",
               after => "# rules",
            }
->
  file_line { "Adding HDD rule":
               path => "/var/log/lost+found/ma-crush-map.txt",
               line => "rule HDD {\n        ruleset 254\n        type replicated\n        min_size 1\n        max_size 10\n        step take HDD\n        step choose firstn 0 type osd\n        step emit\n}",
               after => "# rules",
            }
->
  exec { "Compile Crushmap":
               command => "crushtool -c /var/log/lost+found/ma-crush-map.txt -o /var/log/lost+found/ma-crush-new-map",
       }
->
  exec { "Upload Crushmap":
               command => "ceph osd setcrushmap -i /var/log/lost+found/ma-crush-new-map",
       }
->
  exec { "Make ssd pool":
               command => "ceph osd pool create $ssd_pool $ssd_pg_num",
       }
->
  exec { "Make HDD pool":
               command => "ceph osd pool create HDD $HDD_pg_num",
       }
->

  exec { "Set crushmap ruleset for ssd":
               command => "ceph osd pool set $ssd_pool crush_ruleset 255",
       }
->
  exec { "Set crushmap ruleset for HDD":
               command => "ceph osd pool set HDD crush_ruleset 254",
       }

   if $file_cinder_type_lock_exists == '' {

  exec {"cinder type":
               command => "cinder --os-username $user --os-password $pass --os-project-name $tenant --os-tenant-name $tenant --os-auth-url $auth_uri --os-region-name $region type-create SSD_volumes_ceph",
         }->
  exec{"cinder type-key":
               command => "cinder --os-username $user --os-password $pass --os-project-name $tenant --os-tenant-name $tenant --os-auth-url $auth_uri --os-region-name $region type-key SSD_volumes_ceph set volume_backend_name=RBD-fast",
             }
      file {"/var/log/lost+found/cinder_ceph_type.lock":
             path => "/var/log/lost+found/cinder_ceph_type.lock",
             ensure => "file",
  }  

}
}
}
