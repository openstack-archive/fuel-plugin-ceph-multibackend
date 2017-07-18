Facter.add(:rbd_secret) do
  setcode do
    rbd_secret = Facter::Util::Resolution.exec('grep ^rbd_secret_uuid /etc/cinder/cinder.conf | cut -d"=" -f2 | head -1')
  end
end
