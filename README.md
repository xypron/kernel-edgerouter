<h1>kernel-edgerouter</h1>

This package provides scripts to build the Linux kernel for the
Ubiquity EdgeRouter Lite.

<h2>Debian package</h2>

Call ./build-dpkg.sh to build a Debian package.

The package can be installed with

```
sudo dpkg -i edgerouter-kernel-image_<version>_mips.deb
```

It can be uninstalled with

```
sudo apt-get remove edgerouter-kernel-image
```

The Debian package installation routine shows a list of available
kernels and asks which of them shall be copied to /boot/uboot/vmlinux.

This assumes that the partition from which u-boot reads the kernel is
mounted as /boot/uboot.

<h2>Manual build and installation</h2>

To build the kernel without Debian packaging run

```
make
sudo make install
```

The install step copies the kernel as file &lt;version&gt;.vmlinux
to directory /boot. It has to be copied manually to the partition used by
u-boot.

