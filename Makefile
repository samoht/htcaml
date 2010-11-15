PA_FILES=\
htcaml.cmxa htcaml.cma \
htcaml_ast.mli htcaml_ast.cmi htcaml_ast.cmx \
htcaml_parser.mli htcaml_parser.cmi htcaml_parser.cmx \
htcaml_printer.mli htcaml_printer.cmi htcaml_printer.cmx \
htcaml_quotations.cmi htcaml_quotations.cmx \
htcaml_top.cmo \
xhtml.cmi xhtml.cmx

LIB_FILES = html.cmx html.cmo html.cmi

BFILES = $(addprefix _build/pa_lib/,$(PA_FILES)) \
         $(addprefix _build/lib/,$(LIB_FILES))

INCLS = $(shell ocamlfind query dyntype.syntax -predicates syntax,preprocessor -r -format "-I %d %a") \
        $(shell ocamlfind query xmlm -predicates byte -r -format "-I %d %a") \
        $(shell ocamlfind query str -predicates byte -r -format "-I %d %a")
all:
	ocamlbuild htcaml.cma htcaml_top.cmo htcaml.cmxa
	ocamlbuild -pp "camlp4o $(INCLS) pa_lib/htcaml.cma" html.cmo html.cmx

install:
	ocamlfind install htcaml META $(BFILES)

uninstall:
	ocamlfind remove htcaml

clean:
	ocamlbuild -clean
	rm -rf test_exp.ml test.cmo test.cmx test.cmi test.o test_exp *~

.PHONY: test
test: all
	ocamlbuild -pp "camlp4o $(INCLS) pa_lib/htcaml.cma" test.byte --

.PHONY: test_exp
test_exp: test.ml
	camlp4orf $(INCLS) _build/htcaml.cma test.ml -printer o > test_exp.ml
	ocamlc $(INCLS) -annot -I _build/ html.cmo test_exp.ml -o test_exp

debug: all
	camlp4orf $(INCLS) _build/htcaml.cma test.ml

