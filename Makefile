TAG=4.7

all: prepare build copy

prepare:
	test -d linux || git clone -v \
	https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git \
	linux
	cd linux && git fetch
	gpg --list-keys 79BE3E4300411886 || \
	gpg --keyserver keys.gnupg.net --recv-key 79BE3E4300411886
	gpg --list-keys 38DBBDC86092693E || \
	gpg --keyserver keys.gnupg.net --recv-key 38DBBDC86092693E

build:
	cd linux && git verify-tag v$(TAG) 2>&1 | \
	grep '647F 2865 4894 E3BD 4571  99BE 38DB BDC8 6092 693E' || \
	git verify-tag v$(TAG) 2>&1 | \
	grep 'ABAF 11C6 5A29 70B1 30AB  E3C4 79BE 3E43 0041 1886'
	cd linux && git checkout v$(TAG)
	cd linux && ( git branch -D build || true )
	cd linux && git checkout -b build
	test ! -f patch/patch-$(TAG) || ( cd linux && ../patch/patch-$(TAG) )
	cd linux && make distclean
	cp config/config-$(TAG) linux/.config
	cd linux && make oldconfig
	cd linux && make -j3 vmlinux firmware modules

copy:
	rm linux/deploy -rf
	mkdir -p linux/deploy
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cp linux/.config linux/deploy/config-$$VERSION
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cp linux/vmlinux linux/deploy/$$VERSION.vmlinux
	cd linux && make modules_install INSTALL_MOD_PATH=deploy
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cd linux && make headers_install \
	INSTALL_HDR_PATH=deploy/usr/src/linux-headers-$$VERSION
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	mkdir -p -m 755 linux/deploy/lib/firmware/$$VERSION; true
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	mv linux/deploy/lib/firmware/* \
	linux/deploy/lib/firmware/$$VERSION; true
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cd linux/deploy && tar -czf $$VERSION-modules-firmware.tar.gz lib
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cd linux/deploy && tar -czf $$VERSION-headers.tar.gz usr

install:
	mkdir -p -m 755 $(DESTDIR)/boot;true
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cp linux/deploy/$$VERSION.vmlinux $(DESTDIR)/boot;true
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cp linux/deploy/config-$$VERSION $(DESTDIR)/boot;true
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cp linux/deploy/$$VERSION-modules-firmware.tar.gz $(DESTDIR)/boot;true
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	cp linux/deploy/$$VERSION-headers.tar.gz $(DESTDIR)/boot;true
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	tar -xzf linux/deploy/$$VERSION-modules-firmware.tar.gz -C $(DESTDIR)/
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	tar -xzf linux/deploy/$$VERSION-headers.tar.gz -C $(DESTDIR)/

uninstall:
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	rm $(DESTDIR)/lib/modules/$$VERSION -rf
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	rm $(DESTDIR)/lib/firmware/$$VERSION -rf
	VERSION=$$(cd linux && make --no-print-directory kernelversion) && \
	rm $(DESTDIR)/usr/src/linux-headers-$$VERSION -rf

clean:
	test -d linux && cd linux && rm -f .config || true
	test -d linux && cd linux git clean -df || true

