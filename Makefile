CMAKE=cmake -DCMAKE_INSTALL_PREFIX=/usr

TARGETS = $(shell find . -mindepth 2 -maxdepth 2 -type f -name CMakeLists.txt | cut -f2 -d/)

.PHONY: default
default: fast

.PHONY .ONESHELL: single fast cmake test publish git-push git-pull
single fast cmake test publish git-push git-pull:
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
	$(CMAKE) -C build

.PHONY: fast.cmd
fast.cmd: cmake.cmd
	$(MAKE) -C build -j2

.PHONY: cmake.cmd
cmake.cmd:
	touch CMakeLists.txt

.PHONY: test.cmd
test.cmd:
	@ cd build && ctest --output-on-failure

.PHONY: publish.cmd
publish.cmd:
	doxygen && rsync -rvz build/doc/html/ $(shell pwd | sed -r 's|^.*/([^/]+)/([^/]+)$$|cs.istu.ru:public_html/\1/doc/\2|g')

.PHONY: git-push.cmd
git-push.cmd:
	git push

.PHONY: git-pull.cmd
git-pull.cmd:
	git pull

.PHONY: rebuild
rebuild:
	@ [ -d build ]
	rm -rf build && mkdir build
	cd build && $(CMAKE) ..
	$(MAKE)

.PHONY: %.root
%.root:
	$(MAKE) $(patsubst %,%.$*,$(TARGETS))

.PHONY: %.fast %.single %.test %.publish %.git-push %.git-pull
%.fast %.single %.test %.publish %.git-push %.git-pull:
	@ if [ -d $* ]; then $(MAKE) -C $(shell echo $@ | tr '.' ' ' ) ; fi

# vim:noexpandtab:
