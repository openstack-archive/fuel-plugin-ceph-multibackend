module Puppet::Parser::Functions
newfunction(:get_all_osd_id, :type => :rvalue)  do |args|
  all_osd_id = `find /var/log/lost+found/ -maxdepth 1 | cut -d"/" -f5`
  return all_osd_id
  end
end
