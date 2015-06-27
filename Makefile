CMAKE=cmake -DCMAKE_INSTALL_PREFIX=/usr -G "Sublime Text 2 - Unix Makefiles"

PROCESSORS = $(shell grep processor /proc/cpuinfo | wc -l)
JOBS = $(shell echo '($(PROCESSORS) * 3) / 2' | bc)

.PHONY: default
default: fast

.PHONY: auto
auto:
	@ if [ -f CMakeLists.txt ]; then $(MAKE) $(MFLAGS) cmake-$(TARGET); fi
	@ if [ -f Cargo.toml ]; then $(MAKE) $(MFLAGS) cargo-$(TARGET); fi

.PHONY: prepare rebuild single fast test
prepare rebuild single fast test:
	@ $(MAKE) $(MFLAGS) auto TARGET=$@

sudo-test: test.sudo
sudo-quiet-test: quiet-test.sudo

.PHONY: %.sudo
%.sudo:
	@ sudo $(MAKE) $* $(MFLAGS)
	@ sudo chown $(shell id -u):$(shell id -g) -R .

# CMAKE

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
cmake-single:
	@ $(MAKE) -C build

.PHONY: cmake-fast
cmake-fast:
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

# CARGO

.PHONY: cargo-prepare
cargo-prepare:
	@ [ -f Cargo.toml ]

.PHONY: cargo-rebuild
cargo-rebuild:
	@ [ -f Cargo.toml ]
	cargo clean
	@ $(MAKE)

.PHONY: cargo-single
cargo-single:
	cargo build

.PHONY: cargo-fast
cargo-fast:
	cargo build -j$(JOBS)

.PHONY: cargo-test
cargo-test:
	cargo test

# vim:noexpandtab:
