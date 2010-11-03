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

open Type
open Camlp4.PreCast

let html_of t = "html_of_" ^ t

let c = ref 0

let new_id _loc _ =
  incr c;
  let v = "var" ^ string_of_int !c in
  <:patt< $lid:v$ >>, <:expr< $lid:v$ >>
;;

let create_class _loc n body =
  <:expr< Html.Tag
    "div"
    (Html.Prop 
       (Html.String "class")
       (Html.String $str:n$))
    $body$ >>

let expr_list_of_list _loc exprs =
  match List.rev exprs with
  | []   -> <:expr< [] >>
  | h::t -> List.fold_left (fun accu x -> <:expr< [ $x$ :: $accu$ ] >>) <:expr< [ $h$ ] >> t

let gen_html (_loc, n, t) =
  let defs = ref [] in
  let rec aux id = function
	  | Unit     -> <:expr< >>
	  | Bool     -> <:expr< Html.String (string_of_bool $id$) >>
    | Float    -> <:expr< Html.String (string_of_float $id$) >>
    | Char     -> <:expr< Html.String (String.make 1 $id$) >>
    | String   -> <:expr< Html.String $id$ >>
	  | Int i    -> <:expr< Html.String (string_of_int $id$) >>
	  | Enum t   ->
        let pid, eid = new_id _loc () in
        <:expr< Html.t_of_list (List.map (fun $pid$ -> $aux eid t$) $id$) >>
	  | Tuple t  ->
        let ids = List.map (new_id _loc) t in
        let patts = List.map fst ids in
        let exprs = List.map2 (fun i t -> aux i t) (List.map snd ids) t in
        <:expr<
          let ( $Ast.paCom_of_list patts$ ) = $id$ in
          Html.t_of_list [ $Ast.exSem_of_list exprs$ ]
          >>

	  | Dict d ->
        let exprs = List.map (fun (n,_,t) -> create_class _loc n (aux <:expr< $id$.$lid:n$ >> t)) d in
        let expr = expr_list_of_list _loc exprs in
        <:expr< Html.t_of_list $expr$ >>
	  | Sum _
	  | Option _
	  | Arrow _  -> failwith "not yet supported"

	  | Ext ("Html.t",_)
    | Var "Html.t"-> <:expr< $id$ >>

	  | Ext (n,t) -> create_class _loc n (aux id t)
	  | Rec (n,t) ->
        defs := (n,t) :: !defs;
        create_class _loc n (aux id t)
	  | Var n -> (* XXX: This will not work for recursive values *)
        if List.mem_assoc n !defs then
          create_class _loc n (aux id (List.assoc n !defs))
        else
          failwith n
  in
  let id = <:expr< $lid:n$ >> in
  <:binding< $lid:html_of n$ $lid:n$ = $aux id t$ >>
;;

let () =
  Pa_type_conv.add_generator "html"
		(fun tds ->
			 try
         let _loc = Ast.loc_of_ctyp tds in
			   <:str_item<
				   value $Ast.biAnd_of_list (List.map gen_html (P4_type.create tds))$;
			   >>
       with Not_found ->
         Printf.eprintf "[Internal Error]\n";
         Printexc.print_backtrace stderr;
         exit (-1))
