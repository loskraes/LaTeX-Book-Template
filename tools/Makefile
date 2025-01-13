

RUSTBIN=$(patsubst src/%/src/main.rs,%,$(wildcard src/*/src/main.rs)) $(patsubst %.rs,%,$(notdir $(wildcard src/*/src/bin/*.rs)))
RUSTCARGO=$(patsubst src/%/Cargo.toml,%,$(wildcard src/*/Cargo.toml))

all: $(patsubst %,bin/%,$(RUSTBIN))

$(patsubst %,bin/%,$(RUSTBIN)): $(patsubst %,build/rust-%,$(RUSTCARGO))

.SECONDEXPANSION:
build/rust-%: src/%/Cargo.toml $$(shell find src/% -type f -and ! -path 'src/%/target/*')
	mkdir -p build
	cargo test --manifest-path src/$*/Cargo.toml
	cargo install --path src/$*/ --root . --force
	touch $@

.PHONY: clean
clean: $(patsubst %,clean/rust-%,$(RUSTCARGO))
	rm -f .crates.toml .crates2.json
clean/rust-%:
	cargo clean --manifest-path src/$*/Cargo.toml

dist-clean: clean
	rm -fr build
	rm -fr $(patsubst %,bin/%,$(RUSTBIN))

