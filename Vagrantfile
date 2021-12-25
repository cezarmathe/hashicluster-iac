# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provision "Upload Consul config for running in Vagrant",
    type: "file",
    source: 'configs/consul/99-vagrant.hcl',
    destination: '/tmp/consul-setup/99-vagrant.hcl'
  config.vm.provision "Install Consul config for running in Vagrant",
    type: "shell",
    inline: 'sudo cp /tmp/consul-setup/99-vagrant.hcl /etc/consul.d/99-vagrant.hcl'
  config.vm.provision "Upload Nomad config for running in Vagrant",
    type: "file",
    source: 'configs/nomad/99-vagrant.hcl',
    destination: '/tmp/nomad-setup/99-vagrant.hcl'
  config.vm.provision "Install Nomad config for running in Vagrant",
    type: "shell",
    inline: 'sudo cp /tmp/nomad-setup/99-vagrant.hcl /etc/nomad.d/99-vagrant.hcl'
  config.vm.provision "Restart Consul and Nomad to update their node names",
    type: "shell",
    inline: 'sudo systemctl restart consul nomad'

  # master servers
  (0..2).each do |i|
    config.vm.define "master#{i}" do |master|
      master.vm.box      = "master"
      master.vm.box_url  = "file://out/master/package.box"
      master.vm.hostname = "master#{i}.local"

      master.vm.provision "Upload Vault config for running in Vagrant",
        type: "file",
        source: 'configs/vault/99-vagrant.hcl',
        destination: '/tmp/vault-setup/99-vagrant.hcl'
      master.vm.provision "Install Vault config for running in Vagrant",
        type: "shell",
        inline: 'sudo cp /tmp/vault-setup/99-vagrant.hcl /etc/vault.d/99-vagrant.hcl'
      master.vm.provision "Restart Vault to update its node name",
        type: "shell",
        inline: 'sudo systemctl restart vault'

      master.vm.network "private_network",
        ip: "192.168.56.10#{i}"

      # consul port
      master.vm.network "forwarded_port",
        guest: 8500,
        host: 8500,
        auto_correct: true

      # nomad port
      master.vm.network "forwarded_port",
        guest: 4646,
        host: 4646,
        auto_correct: true,
        guest_ip: "192.168.56.10#{i}"

      # vault port
      master.vm.network "forwarded_port",
        guest: 8200,
        host: 8200,
        auto_correct: true

      master.vm.provider "virtualbox" do |v|
        v.memory = 2048
        v.cpus   = 2
      end
    end
  end

  # worker servers
  (0..4).each do |i|
    config.vm.define "worker#{i}" do |worker|
      worker.vm.box      = "worker"
      worker.vm.box_url  = "file://out/worker/package.box"
      worker.vm.hostname = "worker#{i}.local"

      worker.vm.provider "virtualbox" do |v|
        v.memory = 1024
        v.cpus = 1
      end

      worker.vm.network "private_network",
        ip: "192.168.56.11#{i}"
    end
  end

  # config.vm.provision "Join Consul cluster",
  #   type: "shell",
  #   inline: 'ping -n 1 192.168.56.100 && ping -n 1 192.168.56.100 && consul join 192.168.56.100'
end
