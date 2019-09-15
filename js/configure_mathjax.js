// convinience wrapper to transform backtick blocks to tex. Example
// ```mytext
// A = \lambda n.x
// B = \lambda n.y
// ```
// Gets transformed to (enclosed in a <script> tag so that mathjax can type set it)
// $$\begin{align}
// & A = \lambda n.x\\
// & B = \lambda n.y\\
// \end{align}$$

function wrap_in_script(tex_elt) {
  var text = tex_elt.textContent.split("\n")
                                .filter(s => s != null && s != '')
                                .map(s => "& " + s +" \\\\");
  text.splice(0, 0, "\\begin{align}");
  text.push("\\end{align}");

  var pre_elt = tex_elt.parentNode;
  var root_elt = pre_elt.parentNode;
  var script_elt = document.createElement("script");
  script_elt.type= "math/tex; mode=display";
  script_elt.text = text.join("\n");
  //console.info(script_elt.text);

  script_elt.classList.add("my-tex-container");
  pre_elt.classList.forEach(t => script_elt.classList.add(t));
  root_elt.replaceChild(script_elt, pre_elt);
}

document.addEventListener('DOMContentLoaded',
  e => document.querySelectorAll("pre > code.language-mytex").forEach(wrap_in_script)
);

window.MathJax = {
  tex2jax: {
    inlineMath: [],
    displayMath: [],
    processEscapes: false,
    processEnvironments: false,
    preview: "none"
  }
};
