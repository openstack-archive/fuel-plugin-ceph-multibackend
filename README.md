Ceph Multibackend plugin for Fuel
=================================

Overview
--------

Ceph Multibackend plugin for Fuel extends Mirantis OpenStack functionality by adding
support for Ceph backend in Glance using ceph second pool. It adds new role "Ceph Glance
Backende" with volume partition assignment. This role can be used ONLY with standart 
"Ceph OSD" role on node. 


Compatible Fuel versions
------------------------

9.0


User Guide
----------

1. Create an environment with the Ceph default image backend for Glance.
2. Enable the plugin on the Settings/Storage tab of the Fuel web UI and fill in form
    fields:
   * Ceph pool name - name for new ceph pool
3. Select new node with roles Ceph OSD *AND* Ceph Glance Backend
4. Configure Disks on new node, chose at least one whole disk for role Ceph Glance Backend
  and one for role Ceph-OSD
5. Deploy the environment.


Installation Guide
==================

Ceph Multibackend Plugin for Fuel installation
----------------------------------------------

To install Ceph Multibackend plugin, follow these steps:

1. Download the plugin
    git clone https://github.com/openstack/fuel-plugin-ceph-multibackend

2. Copy the plugin on already installed Fuel Master node; ssh can be used for
    that. If you do not have the Fuel Master node yet, see
    [Quick Start Guide](https://software.mirantis.com/quick-start/):

        # scp fuel-plugin-ceph_multibackend-1.7.1-1.noarch.rpm root@<Fuel_master_ip>:/tmp

3. Log into the Fuel Master node. Install the plugin:

        # cd /tmp
        # fuel plugins --install fuel-plugin-ceph_multibackend-1.7.1-1.noarch.rpm

4. Check if the plugin was installed successfully:

        # fuel plugins
        id | name                            | version | package_version
        ---|---------------------------------|---------|----------------
        1  | fuel-plugin-ceph_multibackend   | 1.7.1  | 4.0.0


Requirements
------------

| Requirement                      | Version/Comment |
|:---------------------------------|:----------------|
| Mirantis OpenStack compatibility | 9.0             |


Limitations
-----------

Role Ceph Glance Backend can be used only on nodes with active Ceph OSD role.
