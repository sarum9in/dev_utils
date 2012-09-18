CMAKE=cmake -DCMAKE_INSTALL_PREFIX=/usr

TARGETS = $(shell echo */CMakeLists.txt | cut -f1 -d/)

.PHONY: default
default: fast

.PHONY .ONESHELL: single fast cmake test publish
single fast cmake test publish:
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

.PHONY: rebuild
rebuild:
	@ [ -d build ]
	rm -rf build && mkdir build
	cd build && $(CMAKE) ..
	$(MAKE)

.PHONY: %.root
%.root:
	$(MAKE) $(patsubst %,%.$*,$(TARGETS))

.PHONY: %.fast %.single %.test %.publish
%.fast %.single %.test %.publish:
	@ if [ -d $* ]; then $(MAKE) -C $(shell echo $@ | tr '.' ' ' ) ; fi

# vim:noexpandtab:
