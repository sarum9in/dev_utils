CMAKE=cmake -DCMAKE_INSTALL_PREFIX=/usr

TARGETS = $(shell echo */CMakeLists.txt | cut -f1 -d/)

.PHONY:
default: fast

.PHONY .ONESHELL:
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

.PHONY:
single.cmd: cmake.cmd
	$(CMAKE) -C build

.PHONY:
fast.cmd: cmake.cmd
	$(MAKE) -C build -j3

.PHONY:
cmake.cmd:
	touch CMakeLists.txt

.PHONY:
test.cmd:
	@ cd build && ctest --output-on-failure

.PHONY:
publish.cmd:
	doxygen && rsync -rvz build/doc/html/ $(shell pwd | sed -r 's|^.*/([^/]+)/([^/]+)$$|cs.istu.ru:public_html/\1/doc/\2|g')

.PHONY:
rebuild:
	@ [ -d build ]
	rm -rf build && mkdir build
	cd build && $(CMAKE) ..
	$(MAKE)

.PHONY:
%.root:
	$(MAKE) $(patsubst %,%.$*,$(TARGETS))

.PHONY:
%.fast %.single %.test %.publish:
	@ if [ -d $* ]; then $(MAKE) -C $(shell echo $@ | tr '.' ' ' ) ; fi

# vim:noexpandtab:
