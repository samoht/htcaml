NAME      = htcaml

PA_FILES  = htcaml_ast htcaml_parser htcaml_printer htcaml_quotations xhtml
LIB_FILES = html

INCLS = \
		$(shell ocamlfind query dyntype.syntax -predicates syntax,preprocessor -r -format "-I %d %a") \
    $(shell ocamlfind query xmlm -predicates byte -r -format "-I %d %a") \
    $(shell ocamlfind query str -predicates byte -r -format "-I %d %a")





##########################################################
NAME_FILES = _build/pa_lib/pa_$(NAME).cmxa \
             _build/pa_lib/pa_$(NAME).cma \
             _build/lib/$(NAME).cma \
             _build/lib/$(NAME).cma

PA_FILES = $(addprefix _build/pa_lib/,$(PA_FILES)) \
PA_FILES = $(addsuffix .cmi,$(PA_FILES)) \
           $(addsuffix .cmo,$(PA_FILES)) \
           $(addsuffix .cmx,$(PA_FILES))

LIB_FILES = $(addprefix _build/pa_lib/,$(LIB_FILES)) \
LIB_FILES = $(addsuffix .cmi,$(LIB_FILES)) \
            $(addsuffix .cmo,$(LIB_FILES)) \
            $(addsuffix .cmx,$(LIB_FILES))

FILES = $(NAME_FILES) $(PA_FILES) $(LIB_FILES) _build/pa_lib/$(NAME)_top.cmo

all:
	ocamlbuild pa_$(NAME).cma pa_$(NAME).cmxa $(NAME)_top.cmo
	ocamlbuild -pp "camlp4o $(INCLS) pa_lib/pa_$(NAME).cma" $(NAME).cmxa html.cma

install:
	ocamlfind install $(NAME) META $(BFILES)

uninstall:
	ocamlfind remove $(NAME)

clean:
	ocamlbuild -clean
	rm -rf test_exp.ml test.cmo test.cmx test.cmi test.o test_exp *~

.PHONY: test
test: all
	ocamlbuild -pp "camlp4o $(INCLS) pa_lib/pa_$(NAME).cma" test.byte --

.PHONY: test_exp
test_exp: test.ml
	camlp4orf $(INCLS) _build/pa_$(NAME).cma test.ml -printer o > test_exp.ml
	ocamlc $(INCLS) -annot -I _build/ html.cmo test_exp.ml -o test_exp

debug: all
	camlp4orf $(INCLS) _build/pa_$(NAME).cma test.ml

