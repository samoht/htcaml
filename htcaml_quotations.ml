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

open Camlp4.PreCast

module Q = Syntax.Quotation
module AQ = Syntax.AntiquotSyntax

let destruct_aq s =
  try
    let pos = String.index s ':' in
    let len = String.length s in
    let name = String.sub s 0 pos
    and code = String.sub s (pos + 1) (len - pos - 1) in
    name, code
  with Not_found ->
    "", s

let aq_expander =
object
  inherit Ast.map as super
  method expr =
    function
      | Ast.ExAnt (_loc, s) ->
        let n, c = destruct_aq s in
        let e = AQ.parse_expr _loc c in
        let fn = <:expr< (fun accu (k,v) -> Html.Seq (accu, Html.Prop (Html.String k, Html.String v))) >> in
        begin match n with
        | "int"   -> <:expr< Html.String (string_of_int $e$) >> 
        | "flo"   -> <:expr< Html.String (string_of_float $e$) >>
        | "str"   -> <:expr< Html.String $e$ >>
        | "list"  -> <:expr< Html.t_of_list $e$ >> 
        | "alist" -> <:expr< List.fold_left $fn$ Html.Nil $e$ >> 
        | _ -> e
        end
      | e -> super#expr e
end

let parse_quot_string loc s : Htcaml_ast.t =
  Htcaml_location.set loc;
  let res = Htcaml_parser.main Htcaml_lexer.token (Lexing.from_string s) in
  Htcaml_location.set Loc.ghost;
  res

let expand_expr loc _ s =
  let ast = parse_quot_string loc s in
  let meta_ast = Htcaml_ast.meta_t loc ast in
  aq_expander#expr meta_ast

let expand_str_item loc _ s =
  let exp_ast = expand_expr loc None s in
  <:str_item@loc< $exp:exp_ast$ >>

;;

Q.add "html" Q.DynAst.expr_tag expand_expr;
Q.add "html" Q.DynAst.str_item_tag expand_str_item
