(*
 * Copyright (c) 2010 Thomas Gazagnaire <thomas@gazagnaire.com>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *)

open Camlp4.PreCast
open Htcaml_ast

module Gram = MakeGram(Lexer)

let htcaml_eoi = Gram.Entry.mk "htcaml_eoi"

let parse_htcaml_eoi loc s = Gram.parse_string htcaml_eoi loc s

let debug = ref false

let debug (fmt: ('a , unit, string, unit) format4) =
  if !debug then
    Printf.kprintf (fun s -> print_string s) fmt
  else
    Printf.kprintf (fun s -> ()) fmt

EXTEND Gram
  GLOBAL: htcaml_eoi;

  str: [[
      s = LIDENT    -> debug "LIDENT(%s) " s; s
    | s = UIDENT    -> debug "UIDENT(%s) " s; s
    | "-"; s = SELF -> debug "-(%s) " s; "-" ^ s
    | "#"; s = SELF -> debug "#(%s) " s; "#" ^ s
    | "#"; s = SELF -> debug "#(%s) " s; "#" ^ s
    | "."; s = SELF -> debug ".(%s) " s; "." ^ s
    | "."           -> debug ". "; "."
    | s1 = SELF; "-"; s2 = SELF -> debug "(%s-%s) " s1 s2; s1 ^ s2
    | s = STRING    -> debug "STRING(%S) " s; s
    | i = INT       -> debug "INT(%s) " i; i
    | f = FLOAT     -> debug "FLOAT(%s) " f; f
 ]];

  htcaml_seq: [[
	  hd = htcaml ->  hd
    | hd = htcaml ; tl = SELF -> debug "SEQ "; Seq (hd, tl)
    | -> Nil
  ]];

  htcaml: [[
      s = str            -> String s
    | "<"; "br"; ">"     -> debug "BR  "; Br
    | "<"; "BR"; ">"     -> debug "BR  "; Br

    | "<"; s = str; ">"; e = htcaml_seq; "</>" ->
        debug "TAG(%s) " s; Tag (s, Nil, e)
    | "<"; s = str; l = htcaml_seq; ">"; e = htcaml_seq; "</>" ->
        debug "TAG2(%s) " s;
        Tag (s, l, e)

    | s1 = SELF; "="; s2 = SELF ->
       debug "PROP ";
       Prop (s1, s2)

    | `ANTIQUOT (""|"int"|"flo"|"str"|"list"|"alist" as n, s) ->
        debug "ANTI(%s:%s) " n s; Ant (_loc, n ^ ":" ^ s)
  ]];

  htcaml_eoi: [[ x = htcaml_seq; EOI -> debug "\n"; x ]];
END
