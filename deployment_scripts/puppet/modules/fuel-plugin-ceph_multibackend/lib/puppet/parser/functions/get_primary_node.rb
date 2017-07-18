module Puppet::Parser::Functions
newfunction(:get_primary_node, :type => :rvalue, :doc => <<-EOS
Return a primary node fqdn that have specific node role.
example:
  get_target_disk($nodes_hash, 'primaray-controller')
EOS
) do |args|
  node_hash, role = args
  noda = Array.new
  node_hash.each do |node|
       if node['role'] == role then
         noda << node['fqdn']
       end
    end
   return noda
   end
end
# vim: set ts=2 sw=2 et 
