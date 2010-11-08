(*
 * Copyright (c) 2010 Thomas Gazagnaire <thomas@gazagnaire.org>
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

open Htcaml_ast

let is_quotation str =
  str.[0] = '$' && str.[String.length str - 1] = '$'

let get_quotation str =
  String.sub str 1 (String.length str - 3)

let make str =
  if is_quotation str then
    Ant (Camlp4.PreCast.Loc.ghost, get_quotation str)
  else
    String str

let input i =
  let el ((_,name), attrs) body =
    let name = make name in
    let attrs = List.map (fun ((_,k),v) -> Prop (make k, make v)) attrs in
    Tag (name, t_of_list attrs, t_of_list body) in
  let data str =
    make str in
  Xmlm.input_tree ~el ~data i

let parse str =
  let entity str =
    if is_quotation str then
      Some str
    else
      None in
  let enc = Some `UTF_8 in
  let i = Xmlm.make_input ~enc ~entity (`String (0, str)) in
  input i
  
