# **postinstall.sh** is a script executed after Debian/Ubuntu has been
# installed and restarted. There is no user interaction so all commands must
# be able to run in a non-interactive mode.
#
# If any package install time questions need to be set, you can use
# `preeseed.cfg` to populate the settings.

### Setup Variables

# The version of Ruby to be installed supporting the Chef and Puppet gems
ruby_ver="1.8.7-p358"

# The base path to the Ruby used for the Chef and Puppet gems
ruby_home="/opt/vagrant_ruby"

# The non-root user that will be created. By vagrant conventions, this should
# be `"vagrant"`.
account="vagrant"

# Enable truly non interactive apt-get installs
export DEBIAN_FRONTEND=noninteractive

# Determine the platform (i.e. Debian or Ubuntu) and platform version
platform="$(lsb_release -i -s)"
platform_version="$(lsb_release -s -r)"

# Run the script in debug mode
set -x

### Customize Sudoers

# The main user (`vagrant` in our case) needs to have **password-less** sudo
# access as described in the Vagrant base box
# [documentation](http://vagrantup.com/docs/base_boxes.html#setup_permissions).
# This user belongs to the `admin`/`sudo` group, so we'll change that line.
sed -i -e '/Defaults\s\+env_reset/a Defaults\texempt_group=admin' /etc/sudoers
case "$platform" in
  Debian)
      sed -i -e 's/%sudo ALL=(ALL) ALL/%sudo ALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers
    ;;
  Ubuntu)
    groupadd -r admin || true
    usermod -a -G admin $account
    sed -i -e 's/%admin ALL=(ALL) ALL/%admin ALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers
    ;;
esac

### Other setup

# Set the LC_CTYPE so that auto-completion works and such.
echo "LC_ALL=\"en_US\"" > /etc/default/locale

### Installing Ruby

#### Compiling Ruby

# The choice was made by the Vagrant and VeeWee authors to compile a Ruby from
# source so that the user of this base box can install their own Rubies using
# packages, RVM, source, etc. It will be installed into $ruby_home so as not
# to collide with /usr/local.
#
# Currently we must install Ruby 1.8 since Puppet doesn't fully support Ruby
# 1.9 yet.

# Install packages necessary to compile Ruby from source
case "$platform" in
  Debian)
    apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline5-dev make curl git-core
    ;;
  Ubuntu)
    apt-get -y install build-essential zlib1g-dev libssl-dev \
      libreadline-dev make curl git-core
    ;;
esac

# Use ruby-build to install Ruby
clone_dir=/tmp/ruby-build-$$
git clone https://github.com/sstephenson/ruby-build.git $clone_dir
$clone_dir/bin/ruby-build "$ruby_ver" "$ruby_home"
rm -rf $clone_dir
unset clone_dir

### Installing Chef and Puppet Gems

# Install prerequisite gems used by Chef and Puppet
${ruby_home}/bin/gem install polyglot net-ssh-gateway mime-types --no-ri --no-rdoc

# The Vagrant base box
# [documentation](http://vagrantup.com/docs/base_boxes.html#boot_and_setup_basic_software)
# specifies that both the Puppet and Chef gems should be installed to qualify
# as a complete Vagrant base box.
${ruby_home}/bin/gem install chef --no-ri --no-rdoc
${ruby_home}/bin/gem install puppet --no-ri --no-rdoc

# Add the Puppet group so Puppet runs without issue
groupadd puppet

# If a packaged Ruby or RVM is installed then the path to the Chef and Puppet
# binaries will be "lost". To guard against this, we'll add the compiled Ruby's
# bin directory to PATH.
echo "PATH=\$PATH:${ruby_home}/bin" >/etc/profile.d/vagrant_ruby.sh

### Vagrant SSH Keys

# Since Vagrant only supports key-based authentication for SSH, we must
# set up the vagrant user to use key-based authentication. We can get the
# public key used by the Vagrant gem directly from its Github repository.
vssh="/home/${account}/.ssh"
mkdir -p $vssh
chmod 700 $vssh
(cd $vssh &&
  wget --no-check-certificate \
    'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' \
    -O $vssh/authorized_keys)
chmod 0600 $vssh/authorized_keys
chown -R ${account}:vagrant $vssh
unset vssh

### VirtualBox Guest Additions

# The netboot installs the VirtualBox support (old) so we have to remove it
apt-get -y remove virtualbox-ose-guest-dkms
apt-get -y remove virtualbox-ose-guest-utils

# The Guest Additions installer will require the use of the linux headers, so
# we'll install it for the moment
apt-get -y install linux-headers-$(uname -r)

# Now use the current VirtualBox guest additions that VeeWee uploaded, mount,
# and install it
VBOX_VERSION=$(cat /home/${account}/.vbox_version)
mount -o loop /home/$account/VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
yes|sh /mnt/VBoxLinuxAdditions.run
umount /mnt

# Cleanup the downloaded ISO
rm -f /home/$account/VBoxGuestAdditions_$VBOX_VERSION.iso

# Remove the linux headers to keep things pristine
apt-get -y remove linux-headers-$(uname -r)

### Misc. Tweaks

# Install NFS client
apt-get -y install nfs-common

# Tweak sshd to prevent DNS resolution (speed up logins)
echo 'UseDNS no' >> /etc/ssh/sshd_config

# Customize the message of the day
case "$platform" in
  Debian)
    echo 'Welcome to your Vagrant-built virtual machine.' > /var/run/motd
    ;;
  Ubuntu)
    echo 'Welcome to your Vagrant-built virtual machine.' > /etc/motd.tail
    ;;
esac

# Record when the basebox was built
date > /etc/vagrant_box_build_time

# Networking - This works around issue #391

cat <<EOF > /etc/rc.local
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

# Make sure eth0 is working. This works around Vagrant issue #391
dhclient eth0

exit 0
EOF

### Clean up

# Remove the build tools to keep things pristine
apt-get -y remove build-essential make curl git-core

apt-get -y autoremove
apt-get -y clean

# Removing leftover leases and persistent rules
rm -f /var/lib/dhcp3/*

# Make sure Udev doesn't block our network, see: http://6.ptmc.org/?p=164
rm /etc/udev/rules.d/70-persistent-net.rules
mkdir /etc/udev/rules.d/70-persistent-net.rules
rm -rf /dev/.udev/
rm /lib/udev/rules.d/75-persistent-net-generator.rules

# Remove any temporary work files, including the postinstall.sh script
rm -f /home/${account}/{*.iso,postinstall*.sh}

### Compress Image Size

# Zero out the free space to save space in the final image
dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY

exit

# And we're done.
