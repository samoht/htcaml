type link = {
  contents: string;
  href: string;
} with html

let html_of_link l : Html.t =
  <:html< <a href=$str:l.href$>$str:l.contents$</a> >>

type body = {
  left : Html.t;
  right: Html.t;
} with html
  
let l1 = {
  contents="john";
  href="http://www.johndoe.com"
}

let b1 = {
  left= <:html< Gauuche >>;
  right= <:html< Droiiite >>
}

let bold b = <:html< <b> $str:b$ </b> >> ;;

let me = "Thomas"
let here = <:html< <a href="http://gazagnaire.org">here</a> >>


let title = <:html< <h1>Hello world</h1> >>;;

let body = <:html<
  My $bold "name"$ is $str:me$.
  <br/>
  You can find my webpage $here$. héhé.
>>;;

let tag1 = [ "class", "tag1" ]
let tag2 = <:html<class="tag2">> (* XXX: no space/tab in the quotation *)

let page = <:html<
<html>
  <body>
    $html_of_body b1$
    $html_of_link l1$
    $list:[title; body]$
    <br/>
    <div $alist:tag1$ $attrs:tag2$>tag</div>
    <a href=$str:(me ^ ".html")$ class="foo">$str:me$</a>
    $Html.Code.ocaml "let f x = if x = then raise \"foo\""$
  </body>
</html> >>

let s = Html.to_string page
let _ = Printf.printf "%s\n%!" s 


let _ = <:html< if then else in and or match >>;;
let _ = <:html< <meta contents="foo" href="bar"/> >>;;

let _ =
  let foo = "foo" in
  <:html<
    <link rel="stylesheet" href=$str:foo$ type="text/css" media="all"/>
  >>


(* Imported from dyntype/lib_test/test_type.ml *)
module M = struct type t = int with html end

type i1 = int32
and  i2 = int
and  i3 = int64
and  i4 = ( int32 * int * int64 )
and  p =
  | One of string * int array
  | Two of t
  | Three of x option list

and pp = [ `Poly1 | `Poly2 | `Poly3 of int ]

and t = {
  t1: M.t;
  mutable t2: string;
  t3: x
} and x = {
  x1: t array;
  x2: int64
} and f = {
  mutable f1: int;
  mutable f2: string list;
  f3: string;
  f4: int64;
  f5: char array;
} and tu = ( int  * f * pp )

with html

type o =
  < x: f; y: x; z: string > 
  with html

let _ =
  Printf.printf "%s\n" (Html.to_string (html_of_i3 ~id:"foo" 31L))


(* from http://www-sop.inria.fr/members/Manuel.Serrano/publi/sfp06/article.html *)
let (/) d f =
  match d with 
    | "." 
    | "./" -> f
    | _    -> Filename.concat d f

let hidden p =
  p <> "." && (p.[0] = '.' || p.[0] = '_')

let rec directory_tree root =
  let rec aux path =
    let abs_path = root / path in
    if not (hidden path) && Sys.is_directory abs_path then begin
      let files = Sys.readdir abs_path in
      let files = Array.to_list files in
      let files = List.map (fun file -> path / file) files in
      Html.Tree.Node (path, List.map aux files)
    end else
      Html.Tree.Leaf path in
  aux "."

let html_of_string str = <:html< $str:str$ >>

let dir = <:html<
  My files :
  $Html.Tree.html_of_t html_of_string (directory_tree (Sys.getcwd ()))$
>>

let _ =
  Printf.printf "%s\n" (Html.to_string dir)
