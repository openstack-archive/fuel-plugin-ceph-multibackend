Facter.add(:volume_rbd_pool) do
  setcode do
    volume_rbd_pool = Facter::Util::Resolution.exec('rados lspools | grep volume; echo $?')
  end
end
Facter.add(:image_rbd_pool) do
  setcode do
    image_rbd_pool = Facter::Util::Resolution.exec('rados lspools | grep image; echo $?')
  end
end
