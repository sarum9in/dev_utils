CMAKE=cmake -DCMAKE_INSTALL_PREFIX=/usr

TARGETS = $(shell find . -mindepth 2 -maxdepth 2 -type f -name CMakeLists.txt | cut -f2 -d/)

PROCESSORS = $(shell grep processor /proc/cpuinfo | wc -l)
JOBS = $(shell echo '($(PROCESSORS) * 3) / 2' | bc)

.PHONY: default
default: fast

.PHONY .ONESHELL: single fast cmake test quiet-test publish install git-push git-pull
single fast cmake test quiet-test publish install git-push git-pull:
	@ if [ -d build ]
	@ then
	@     $(MAKE) $@.cmd
	@ elif [ -d ../build ]
	@ then
	@     $(MAKE) -C .. $@
	@ else
	@     $(MAKE) $@.root
	@ fi

.PHONY: single.cmd
single.cmd: cmake.cmd
	$(MAKE) -C build

.PHONY: fast.cmd
fast.cmd: cmake.cmd
	$(MAKE) -C build -j$(JOBS)

.PHONY: cmake.cmd
cmake.cmd:
	touch CMakeLists.txt

.PHONY: test.cmd
test.cmd:
	$(MAKE) -C build test ARGS=--output-on-failure

.PHONY: quiet-test.cmd
quiet-test.cmd:
	@ cd build && ctest

.PHONY: publish.cmd
publish.cmd:
	@ if [ -f Doxyfile ]; then doxygen && rsync -rvz build/doc/html/ $(shell pwd | sed -r 's|^.*/([^/]+)/([^/]+)$$|cs.istu.ru:public_html/\1/doc/\2|g'); fi

.PHONY: install.cmd
install.cmd:
	$(MAKE) -C build install

.PHONY: git-push.cmd
git-push.cmd:
	@ if [ -d .git ]; then git push $(REMOTE) $(BRANCH); fi

.PHONY: git-pull.cmd
git-pull.cmd:
	@ if [ -d .git ]; then git push $(REMOTE) $(BRANCH); fi

.PHONY: rebuild
rebuild:
	@ [ -d build ]
	rm -rf build && mkdir build
	cd build && $(CMAKE) .. && cd ..
	$(MAKE)

sudo-test: test.sudo
sudo-quiet-test: quiet-test.sudo

.PHONY: %.root
%.root:
	$(MAKE) $(patsubst %,%.$*,$(TARGETS))

.PHONY: %.sudo
%.sudo:
	@ sudo $(MAKE) $*.cmd $(MFLAGS)
	@ sudo chown $(shell id -u):$(shell id -g) -R build

.PHONY: %.fast %.single %.test %.quiet-test %.sudo-test %.sudo-quiet-test %.publish %.git-push %.git-pull
%.fast %.single %.test %.quiet-test %.sudo-test %.sudo-quiet-test %.publish %.git-push %.git-pull:
	@ if [ -d $* ]; then $(MAKE) -C $(shell echo $@ | tr '.' ' ' ) ; fi

# vim:noexpandtab:
