CXXFLAGS = -ffast-math -std=c++14 -Iinclude -DCHAISCRIPT_NO_THREADS -Wno-invalid-offsetof -O3
LDFLAGS = -L./lib -lminecraftpe

LPLAYER = -Lout -lplayer_support

MODS = chat command form player test

$(shell mkdir -p objs deps out >/dev/null)

.PHONY: all
all: out/libplayer_support.so out/ChaiSupport.so $(addsuffix .mod,$(addprefix out/,$(MODS)))

.PHONY: clean
clean:
	@rm -rf objs out deps

out/libplayer_support.so: objs/fix.o objs/player_support.o lib/libminecraftpe.so
	@echo LD $@
	@$(CPP) $(LDFLAGS) -shared -fPIC -o $@ $(filter %.o,$^)
out/%.mod: objs/%.o objs/hack.o out/libplayer_support.so lib/libminecraftpe.so
	@echo LD $@
	@$(CPP) $(LDFLAGS) $(LPLAYER) -shared -fPIC -o $@ $(filter %.o,$^)
out/ChaiSupport.so: objs/fix.o objs/main.o out/libplayer_support.so lib/libminecraftpe.so
	@echo LD $@
	@$(CPP) $(LDFLAGS) $(LPLAYER) -shared -fPIC -o $@ $(filter %.o,$^)

.PRECIOUS: deps/%.d
deps/%.d: src/%.cpp
	@echo DP $<
	@$(CPP) $(CXXFLAGS) -MT $(patsubst deps/%.d,objs/%.o,$@) -M -o $@ $<

.PRECIOUS: objs/%.o
objs/%.o: src/%.cpp
objs/%.o: src/%.cpp deps/%.d
	@echo CC $@
	@$(CPP) $(CXXFLAGS) -c -o $@ $<

-include deps/*