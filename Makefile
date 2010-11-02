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
	rm -rf test.exp test.cmo test.cmx test.cmi test.o

test:
	ocamlbuild test.byte --

test.exp: test.ml
	camlp4orf _build/htcaml.cma test.ml -printer o > test.exp

debug: all
	camlp4orf _build/htcaml.cma test.ml

