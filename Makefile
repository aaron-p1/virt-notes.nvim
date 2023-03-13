SRC := $(shell find fennel -name '*.fnl')
OUT := $(patsubst fennel/%.fnl,lua/%.lua,${SRC})

luaGlobals := vim,unpack

all: $(OUT)

lua/%.lua: fennel/%.fnl
	@mkdir -p $(@D)
	fennel --globals $(luaGlobals) --correlate --compile $< > $@

format: $(SRC)
	fnlfmt --fix $<

clean:
	rm -rf lua

.PHONY: all format clean
