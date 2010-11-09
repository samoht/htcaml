A simple XHTML quotation mechanism for ocaml using camlp4.

This library started as a toy-project at the very good
[CUFP tutorial](http://cufp.org/conference/sessions/2010/camlp4-and-template-haskell)
by [Jake Donham](http://www.github.com/jaked) and [Nicolas Pouillard](http://www.github.com/np).
It is now in a working state for bigger projects.

This library includes a modified version of xmlm available [here](http://www.github.com/samoht/xmlm)
 to do not display DTD when it is not needed.

Remark : As we are parsing valid XHTML only, all tags have to be closed. Empty tags (including <br>, <link> or <meta>) are closed using <tag/>.

== Hello World ==

    <:html<
      <html> <body> <h1> Hello World! </h1> </body> </html>
    >>

== Antiquotations ==

   <:html< last modified : $flo:Unix.time ()$ >>

== Attributes ==

   let tag1 = [ "class", "tag1" ]
   let tag2 = <:html< class="tag2" >>
   <:html< <div $alist:tag1$ $tag2$>foo</> >>

== Auto-generated code ==

   let tweet = {
     author = string;
     text = Html.t;
   } with html

will produce:

   val html_of_tweet : tweet -> Html.t

`html_of_tweet { author = "Jonn"; text = <:html< Some <b>text</b>!!! >> }` will look to something similar to :

   <div class="tweet">
     <div class="author">John</div>
     <div class="text"> Some <b>text</b>!!! </div>
   </div>
