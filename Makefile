CMAKE=cmake -DCMAKE_INSTALL_PREFIX=/usr -G "Sublime Text 2 - Unix Makefiles"
CARGO=cargo
PYTHON=python

PROCESSORS = $(shell grep processor /proc/cpuinfo | wc -l)
JOBS = $(shell echo '($(PROCESSORS) * 3) / 2' | bc)

.PHONY: default
default: fast

.PHONY: auto
auto:
	@ if [ -f CMakeLists.txt ]; then $(MAKE) $(MFLAGS) cmake-$(TARGET); fi
	@ if [ -f Cargo.toml ]; then $(MAKE) $(MFLAGS) cargo-$(TARGET); fi
	@ if [ -f setup.py ]; then $(MAKE) $(MFLAGS) python-$(TARGET); fi

.PHONY: prepare rebuild single fast test install
prepare rebuild single fast test install:
	@ $(MAKE) $(MFLAGS) auto TARGET=$@

sudo-test: test.sudo
sudo-quiet-test: quiet-test.sudo

.PHONY: %.sudo
%.sudo:
	@ sudo $(MAKE) $* $(MFLAGS)
	@ sudo chown $(shell id -u):$(shell id -g) -R .

# CMake

.PHONY: cmake-prepare
cmake-prepare:
	@ [ -d build ]
	@ [ -f CMakeLists.txt ]
	touch CMakeLists.txt

.PHONY: cmake-rebuild
cmake-rebuild:
	@ [ -d build ]
	rm -rf build && mkdir build
	cd build && $(CMAKE) .. && cd ..
	@ $(MAKE)

.PHONY: cmake-single
cmake-single: cmake-prepare
	@ $(MAKE) -C build

.PHONY: cmake-fast
cmake-fast: cmake-prepare
	@ $(MAKE) -C build -j$(JOBS)

.PHONY: cmake-install
cmake-install:
	@ [ -d build ]
	@ $(MAKE) -C build install

.PHONY: cmake-test
cmake-test:
	@ [ -d build ]
	@ $(MAKE) -C build test ARGS=--output-on-failure

.PHONY: cmake-quiet-test
cmake-quiet-test:
	@ [ -d build ]
	@ $(MAKE) -C build test

# Cargo

.PHONY: cargo-prepare
cargo-prepare:
	@ [ -f Cargo.toml ]

.PHONY: cargo-rebuild
cargo-rebuild:
	@ [ -f Cargo.toml ]
	$(CARGO) clean
	@ $(MAKE)

.PHONY: cargo-single
cargo-single: cargo-prepare
	$(CARGO) build

.PHONY: cargo-fast
cargo-fast: cargo-prepare
	$(CARGO) build -j$(JOBS)

.PHONY: cargo-test
cargo-test:
	$(CARGO) test

.PHONY: cargo-install
cargo-install:
	@ echo Not implemented!
	@ false

# Python

.PHONY: python-prepare
python-prepare:
	@ [ -f setup.py ]

.PHONY: python-rebuild
python-rebuild:
	@ [ -f setup.py ]
	@ [ -d build ]
	rm -rf build
	@ $(MAKE)

.PHONY: python-single python-fast
python-single python-fast: python-prepare
	$(PYTHON) setup.py build

.PHONY: python-test
python-test:
	$(PYTHON) setup.py test

.PHONY: python-install
python-install:
	$(PYTHON) setup.py install --root=$(DESTDIR)

# vim:noexpandtab:
