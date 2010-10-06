let bold b = <:html< <b> $str:b$ </> >> ;;

let me = "Thomas"
let here = <:html< <a href="http://thomas.gazagnaire.com"> here </> >>


let title = <:html< <h1>Hello world</> >>;;

let body = <:html<
  My $bold "name"$ is $str:me$
  </br>
  You can find my webpage $here$
>>;;

let tag1 = [ "class", "tag1" ]
let tag2 = <:html< class="tag2" >>

let page = <:html<
<html>
  <body>
    $list:[title; body]$
    </br>
    <div $alist:tag1$ $tag2$>tag</>
  </>
</> >>

let s = Html.to_string page
let _ = Printf.printf "%s\n%!" s 


let _ = <:html< if then else in and or match >>;;
let _ = <:html< </meta contents="foo" href="bar"> >>;;

(* XXX: =$ is parsed as a unique token ... so don't forget the white-space (until we have a better lexer) *)
let _ =
  let foo = "foo" in
  <:html<
    <link rel="stylesheet" href= $str:foo$ type="text/css" media="all"> </>
  >>

(*
let aux accu = function
  | []      -> accu
  | c :: t -> aux <:html< $accu$ id=$str:c$ >> t
;;

*)
