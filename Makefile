.PHONY: deps test

REBAR := ./rebar
APPS = erts kernel stdlib sasl crypto compiler inets mnesia public_key runtime_tools snmp syntax_tools tools xmerl webtool
PLT_FILE = .leo_dcerl_dialyzer_plt
DOT_FILE = leo_dcerl.dot
CALL_GRAPH_FILE = leo_dcerl.png

all:
	@$(REBAR) update-deps
	@$(REBAR) get-deps
	@$(REBAR) compile
	@$(REBAR) xref skip_deps=true
	@$(REBAR) eunit skip_deps=true
compile:
	@$(REBAR) compile skip_deps=true
xref:
	@$(REBAR) xref skip_deps=true
eunit:
	@$(REBAR) eunit skip_deps=true
check_plt:
	@$(REBAR) compile
	dialyzer --check_plt --plt $(PLT_FILE) --apps $(APPS)
build_plt:
	@$(REBAR) compile
	dialyzer --build_plt --output_plt $(PLT_FILE) --apps $(APPS)
dialyzer:
	@$(REBAR) compile
	dialyzer -Wno_return --plt $(PLT_FILE) -r ebin/ --dump_callgraph $(DOT_FILE) | fgrep -v -f ./dialyzer.ignore-warnings
typer:
	typer --plt $(PLT_FILE) -I include/ -r src/
doc: compile
	@$(REBAR) doc
callgraph: graphviz
	dot -Tpng -o$(CALL_GRAPH_FILE) $(DOT_FILE)
graphviz:
	$(if $(shell which dot),,$(error "To make the depgraph, you need graphviz installed"))
clean:
	@$(REBAR) clean skip_deps=true
distclean:
	@$(REBAR) delete-deps
	@$(REBAR) clean