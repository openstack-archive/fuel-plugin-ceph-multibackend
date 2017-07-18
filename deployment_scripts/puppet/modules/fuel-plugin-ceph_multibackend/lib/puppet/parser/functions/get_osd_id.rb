module Puppet::Parser::Functions
newfunction(:get_osd_id, :type => :rvalue)  do |args|
  device  = args
  dev = device.join("")
  osd_id = `mount | grep #{dev} | cut -d" " -f3 | cut -d"-" -f2`
  osd_id.delete!("\n")
  return osd_id
 end
end
# vim: set ts=2 sw=2 et :
