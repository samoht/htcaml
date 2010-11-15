NAME      = htcaml

PA_FILES  = htcaml_ast htcaml_parser htcaml_printer htcaml_quotations xhtml
LIB_FILES = html

INCLS = \
		$(shell ocamlfind query dyntype.syntax -predicates syntax,preprocessor -r -format "-I %d %a") \
    $(shell ocamlfind query xmlm -predicates byte -r -format "-I %d %a") \
    $(shell ocamlfind query str -predicates byte -r -format "-I %d %a") \



##########################################################
NAME_FILES = _build/pa_lib/pa_$(NAME).cmxa \
             _build/pa_lib/pa_$(NAME).cma \
             _build/lib/$(NAME).cma \
             _build/lib/$(NAME).cmxa

_PA_FILES = $(addprefix _build/pa_lib/,$(PA_FILES)) \
PA_FILES = $(addsuffix .cmi,$(_PA_FILES)) \
           $(addsuffix .cmo,$(_PA_FILES)) \
           $(addsuffix .cmx,$(_PA_FILES))

_LIB_FILES = $(addprefix _build/pa_lib/,$(LIB_FILES)) \
LIB_FILES = $(addsuffix .cmi,$(_LIB_FILES)) \
            $(addsuffix .cmo,$(_LIB_FILES)) \
            $(addsuffix .cmx,$(_LIB_FILES))

FILES = $(NAME_FILES) $(PA_FILES) $(LIB_FILES) _build/pa_lib/$(NAME)_top.cmo

all:
	ocamlbuild pa_$(NAME).cma pa_$(NAME).cmxa $(NAME)_top.cmo
	ocamlbuild -pp "camlp4o $(INCLS) pa_lib/pa_$(NAME).cma" $(NAME).cmxa $(NAME).cma

install:
	ocamlfind install $(NAME) META $(FILES)

uninstall:
	ocamlfind remove $(NAME)

clean:
	ocamlbuild -clean
	rm -rf test_exp.ml test.cmo test.cmx test.cmi test.o test_exp *~

.PHONY: test
test: all
	ocamlbuild -pp "camlp4o $(INCLS) pa_lib/pa_$(NAME).cma" test.byte --

.PHONY: test_exp
test_exp: lib_test/test.ml
	camlp4orf $(INCLS) _build/pa_lib/pa_$(NAME).cma lib_test/test.ml -printer o > _build/test_exp.ml
	ocamlc $(INCLS) -annot -I _build/lib $(NAME).cma _build/test_exp.ml -o _build/test_exp

debug: all
	camlp4orf $(INCLS) _build/pa_lib/pa_$(NAME).cma test.ml

