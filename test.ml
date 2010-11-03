type link = {
  contents: string;
  href: string;
} with html

let html_of_link l =
  <:html< <a href=$str:"\""^l.href^"\""$>$str:l.contents$</> >>

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

let bold b = <:html< <b> $str:b$ </> >> ;;

let me = "Thomas"
let here = <:html< <a href="http://gazagnaire.org">here</> >>


let title = <:html< <h1>Hello world</> >>;;

let body = <:html<
  My $bold "name"$ is $str:me$.
  <br/>
  You can find my webpage $here$. héhé.
>>;;

let tag1 = [ "class", "tag1" ]
let tag2 = <:html< ^class=tag2^ >>

let page = <:html<
<html>
  <body>
    $html_of_body b1$
    $html_of_link l1$
    $list:[title; body]$
    <br/>
    <div $alist:tag1$ $tag2$>tag</>
    <a href=$str:me ^ ".html"$ class=foo>$str:me$</>
  </>
</> >>

let s = Html.to_string page
let _ = Printf.printf "%s\n%!" s 


let _ = <:html< if then else in and or match >>;;
let _ = <:html< <meta contents="foo" href="bar"/> >>;;

let _ =
  let foo = "foo" in
  <:html<
    <link rel="stylesheet" href=$str:foo$ type="text/css" media="all"/>
  >>
