# -*- mode: ruby -*-
# vim: set ft=ruby :

MACHINES = {
  :otuslinux => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101',
        :ip_addr_libvirt => '192.168.15.101',
	:disks => {
		:sata1 => {
			:dfile => './sata1.vdi',
			:size => 250,
			:port => 1,
                        :size_libvirt => '250M',
                        :dfile_libvirt => 'sata1.qcow2',
                        :dfile_type_libvirt => 'qcow2',
                        :bus_libvirt => 'sata'
		},
		:sata2 => {
                        :dfile => './sata2.vdi',
                        :size => 250, # Megabytes
			:port => 2,
                        :size_libvirt => '250M',
                        :dfile_libvirt => 'sata2.qcow2',
                        :dfile_type_libvirt => 'qcow2',
                        :bus_libvirt => 'sata'
		},
                :sata3 => {
                        :dfile => './sata3.vdi',
                        :size => 250,
                        :port => 3,
                        :size_libvirt => '250M',
                        :dfile_libvirt => 'sata3.qcow2',
                        :dfile_type_libvirt => 'qcow2',
                        :bus_libvirt => 'sata'
                },
                :sata4 => {
                        :dfile => './sata4.vdi',
                        :size => 250, # Megabytes
                        :port => 4,
                        :size_libvirt => '250M',
                        :dfile_libvirt => 'sata4.qcow2',
                        :dfile_type_libvirt => 'qcow2',
                        :bus_libvirt => 'sata'
                },
                :sata5 => {
                        :dfile => './sata5.vdi',
                        :size => 250,
                        :port => 5,
                        :size_libvirt => '250M',
                        :dfile_libvirt => 'sata5.qcow2',
                        :dfile_type_libvirt => 'qcow2',
                        :bus_libvirt => 'sata'
                },
                :sata6 => {
                        :dfile => './sata6.vdi',
                        :size => 250,
                        :port => 6,
                        :size_libvirt => '250M',
                        :dfile_libvirt => 'sata6.qcow2',
                        :dfile_type_libvirt => 'qcow2',
                        :bus_libvirt => 'sata'
                }

	}

		
  },
}

Vagrant.configure("2") do |config|

  MACHINES.each do |boxname, boxconfig|

      config.vm.define boxname do |box|

          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s

          #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset


          box.vm.provider :virtualbox do |vb, override|
                  override.vm.network "private_network", ip: boxconfig[:ip_addr]
            	  vb.customize ["modifyvm", :id, "--memory", "1024"]
		  vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]

		  boxconfig[:disks].each do |dname, dconf|
			  unless File.exist?(dconf[:dfile])
				vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
			  end
			  vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]

		  end
                  
                  override.vm.provision "shell", inline: <<-SHELL
                        mdadm --zero-superblock /dev/sd{b,c,d,e,f,g}
                        mdadm /dev/md0 --create -l 5 -n 6 /dev/sd{b,c,d,e,f,g}
                        mdadm --detail --scan --verbose > /etc/mdadm.conf
                        parted -s /dev/md0 mklabel gpt
                        parted /dev/md0 mkpart primary ext4 0% 20%
                        parted /dev/md0 mkpart primary ext4 20% 40%
                        parted /dev/md0 mkpart primary ext4 40% 60%
                        parted /dev/md0 mkpart primary ext4 60% 80%
                        parted /dev/md0 mkpart primary ext4 80% 100%
                  SHELL
          end

          box.vm.provider :libvirt do |lv, override|
                  override.vm.network "private_network", ip: boxconfig[:ip_addr_libvirt]
                  lv.cpus = 1
                  lv.memory = 1024

                  boxconfig[:disks].each do |dname, dconf|
                      lv.storage :file,
                          :size => dconf[:size_libvirt],
                          :type => dconf[:dfile_type_libvirt],
                          :path => dconf[:dfile_libvirt],
                          :allow_existing => "true",
                          :bus => dconf[:bus_libvirt]
                  end

                  override.vm.provision "shell", inline: <<-SHELL
                        mdadm --zero-superblock /dev/sd{a,b,c,d,e,f}
                        mdadm /dev/md0 --create -l 5 -n 6 /dev/sd{a,b,c,d,e,f}
                        mdadm --detail --scan --verbose > /etc/mdadm.conf
                        parted -s /dev/md0 mklabel gpt
                        parted /dev/md0 mkpart primary ext4 0% 20%
                        parted /dev/md0 mkpart primary ext4 20% 40%
                        parted /dev/md0 mkpart primary ext4 40% 60%
                        parted /dev/md0 mkpart primary ext4 60% 80%
                        parted /dev/md0 mkpart primary ext4 80% 100%
                  SHELL

          end

 	  box.vm.provision "shell", inline: <<-SHELL
	      mkdir -p ~root/.ssh
              cp ~vagrant/.ssh/auth* ~root/.ssh
	      yum install -y mdadm smartmontools hdparm gdisk
  	  SHELL

      end
  end
end

