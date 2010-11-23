You can read a quick introduction to HTCaML [here](http://www.openmirage.org/blog/introduction-to-htcaml).

This library started as a toy-project at the very good
[CUFP tutorial](http://cufp.org/conference/sessions/2010/camlp4-and-template-haskell)
by [Jake Donham](http://www.github.com/jaked) and [Nicolas Pouillard](http://www.github.com/np).
It is now in a working state for bigger projects.

This library needs a modified version of xmlm available [here](http://www.github.com/samoht/xmlm).
The only difference with upstream is that it does not display DTD when there is no DTD (upstream
prints an empty DTD tag).

Remark : As we are parsing valid XHTML only, all tags have to be closed. Empty tags (including `<br>`, `<link>` or `<meta>`) are closed using `<tag/>`.

Hello World
-----------

You can write any valid XHTML inside `<:html< ... >>` quotations:

    <:html<
      <html> <body> <h1> Hello World! </h1> </body> </html>
    >>

Antiquotations
--------------

Inside quotations, you can call back normal ocaml code using `$ ... $`; by default the return
value of the called should be of type Html.t. If it not the case, then you need to help the
compiler to cast the return value into Html.t, using `$type: ...$`.

    <:html< last modified : $flo:Unix.time ()$ >>

Attributes
----------

Node attributes can be handled directly as list of string pairs; the magic key-word to use in the
antiquotation is `$alist: ... $`:

    let tag1 = [ "class", "tag1" ]
    let tag2 = <:html< class="tag2" >>
    <:html< <div $alist:tag1$ $attrs:tag2$>foo</> >>

Auto-generated code
-------------------

Very often, it is quite tedious to derive the right XHTML code from an OCaml definition. Instead,
you can tag the type definition with the keywords `with html` and some code generating the
right XHTML fragments will be produce. As example,

    let tweet = {
      author = string;
      text = Html.t;
    } with html

will produce:

    val html_of_tweet : tweet -> Html.t

And then, `html_of_tweet { author = "Jonn"; text = <:html< Some <b>text</b>!!! >> }`
will generate the following XHTML fragment :

    <div class="tweet">
      <div class="author">John</div>
      <div class="text"> Some <b>text</b>!!! </div>
    </div>
