CMAKE=cmake -DCMAKE_INSTALL_PREFIX=/usr

PROCESSORS = $(shell grep processor /proc/cpuinfo | wc -l)
JOBS = $(shell echo '($(PROCESSORS) * 3) / 2' | bc)

.PHONY: default
default: fast

.PHONY: single
single: cmake
	@ [ -d build ]
	$(MAKE) -C build

.PHONY: fast
fast: cmake
	$(MAKE) -C build -j$(JOBS)

.PHONY: cmake
cmake:
	@ [ -d build ]
	@ [ -f CMakeLists.txt ]
	touch CMakeLists.txt

.PHONY: test
test:
	@ [ -d build ]
	$(MAKE) -C build test ARGS=--output-on-failure

.PHONY: quiet-test
quiet-test:
	@ [ -d build ]
	$(MAKE) -C build test

.PHONY: install
install:
	@ [ -d build ]
	$(MAKE) -C build install

.PHONY: rebuild
rebuild:
	@ [ -d build ]
	rm -rf build && mkdir build
	cd build && $(CMAKE) .. && cd ..
	$(MAKE)

sudo-test: test.sudo
sudo-quiet-test: quiet-test.sudo

.PHONY: %.sudo
%.sudo:
	@ sudo $(MAKE) $* $(MFLAGS)
	@ sudo chown $(shell id -u):$(shell id -g) -R build

# vim:noexpandtab:
