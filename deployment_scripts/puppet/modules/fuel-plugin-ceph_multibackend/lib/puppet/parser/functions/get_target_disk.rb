module Puppet::Parser::Functions
newfunction(:get_target_disk, :type => :rvalue, :doc => <<-EOS
Return a list of disks (node roles are keys) that have the given node role.
example:
  get_target_disk($node_volumes, 'cinder')
EOS
) do |args|
  disks_metadata, role = args
  disks = Array.new
  disks_metadata.each do |disk|
     disk['volumes'].each do |volume|
       if volume['name'] == role and volume['size'] != 0 then
         disks << disk['name']
       end
      end
    end    
   return disks
   end

end
# vim: set ts=2 sw=2 et :
