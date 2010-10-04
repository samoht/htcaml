let bold b = <:html< <b> $str:b$ </> >> ;;

let me = "Thomas"
let here = <:html< <a href="http://thomas.gazagnaire.com"> here </> >>


let title = <:html< <h1>Hello world</> >>;;

let body = <:html<
	My $bold "name"$ is $str:me$.
	<br>
	You can find my webpage $here$. 
>>;;

let page = <:html<
<html>
	 <body>
		  $list:[title; body]$
	 </>
</> >>

let s = Html.to_string page
let _ = Printf.printf "%s\n%!" s 
