TAG=3.17.1

all: build copy

build:
	test -d linux || git clone -v \
	https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git \
	linux
	cp config/config-$(TAG) linux/.config
	cd linux && git fetch
	gpg --list-keys 00411886 || \
	gpg --keyserver keys.gnupg.net --recv-key 00411886
	gpg --list-keys 6092693E || \
	gpg --keyserver keys.gnupg.net --recv-key 6092693E
	cd linux && git verify-tag v$(TAG)
	cd linux && git checkout v$(TAG)
	cd linux && make clean
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

