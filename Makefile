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

.PHONY: clean rebuild single fast test install
clean rebuild single fast test install:
	@ $(MAKE) $(MFLAGS) auto TARGET=$@

sudo-test: test.sudo
sudo-quiet-test: quiet-test.sudo

.PHONY: %.sudo
%.sudo:
	@ sudo $(MAKE) $* $(MFLAGS)
	@ sudo chown $(shell id -u):$(shell id -g) -R .

# CMake

.PHONY: cmake-assert
cmake-assert:
	@ [ -d build ]
	@ [ -f CMakeLists.txt ]

.PHONY: cmake-update
cmake-prepare: cmake-assert
	touch CMakeLists.txt

.PHONY: cmake-clean
cmake-clean: cmake-assert
	@ $(MAKE) -C build clean

.PHONY: cmake-rebuild
cmake-rebuild: cmake-assert
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
cmake-install: cmake-assert
	@ $(MAKE) -C build install

.PHONY: cmake-test
cmake-test: cmake-assert
	@ $(MAKE) -C build test ARGS=--output-on-failure

.PHONY: cmake-quiet-test
cmake-quiet-test:
	@ [ -d build ]
	@ $(MAKE) -C build test

# Cargo

.PHONY: cargo-assert
cargo-prepare:
	@ [ -f Cargo.toml ]

.PHONY: cargo-clean
cargo-clean: cargo-assert
	@ cargo clean

.PHONY: cargo-rebuild
cargo-rebuild: cargo-clean
	@ $(MAKE)

.PHONY: cargo-single
cargo-single: cargo-assert
	$(CARGO) build

.PHONY: cargo-fast
cargo-fast: cargo-assert
	$(CARGO) build -j$(JOBS)

.PHONY: cargo-test
cargo-test: cargo-assert
	$(CARGO) test

.PHONY: cargo-install
cargo-install: cargo-assert
	@ echo Not implemented!
	@ false

# Python

.PHONY: python-assert
python-prepare:
	@ [ -f setup.py ]

.PHONY: python-rebuild
python-rebuild: python-assert
	rm -rf build
	@ $(MAKE)

.PHONY: python-single python-fast
python-single python-fast: python-assert
	$(PYTHON) setup.py build

.PHONY: python-test
python-test: python-assert
	$(PYTHON) setup.py test

.PHONY: python-install
python-install: python-assert
	$(PYTHON) setup.py install --root=$(DESTDIR)

# vim:noexpandtab:
