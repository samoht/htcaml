FILES=\
htcaml.cmxa htcaml.cma \
htcaml_ast.mli htcaml_ast.cmi htcaml_ast.cmx \
htcaml_parser.mli htcaml_parser.cmi htcaml_parser.cmx \
htcaml_printer.mli htcaml_printer.cmi htcaml_printer.cmx \
htcaml_quotations.cmi htcaml_quotations.cmx \
htcaml_top.cmo \
html.cmx html.cmo html.cmi

BFILES=$(addprefix _build/,$(FILES))

all:
	ocamlbuild htcaml.cma htcaml_top.cmo htcaml.cmxa html.cmo html.cmx

install:
	ocamlfind install htcaml META $(BFILES)

uninstall:
	ocamlfind remove htcaml

clean:
	ocamlbuild -clean
	rm -rf test_exp.ml test.cmo test.cmx test.cmi test.o

.PHONY: test
test: all
	ocamlbuild test.byte --

INCLS = $(shell ocamlfind query dyntype.syntax -predicates syntax,preprocessor -r -format "-I %d %a")
BINCLS = $(shell ocamlfind query str -predicates byte -r -format "-I %d %a")

.PHONY: test_exp
test_exp: test.ml
	camlp4orf $(INCLS) _build/htcaml.cma test.ml -printer o > test_exp.ml
	ocamlc $(BINCLS) -I _build/ html.cmo test_exp.ml -o test

debug: all
	camlp4orf $(INCLS) _build/htcaml.cma test.ml

