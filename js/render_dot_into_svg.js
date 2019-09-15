// Looks for all elements with dot code and calls viz.js on them to generate an svg.

// By constructing this way, we get synchronous execution (even if it returns promises)
var global_viz = new Viz();

document.addEventListener('DOMContentLoaded', function(event) {
  document.querySelectorAll("pre > code.language-myviz").forEach(function(dot_elt) {
    dot_elt.hidden = true;
    var text = dot_elt.textContent;
    // this takes some time, it will trigger warnings because we are blocking the listener thread for tool long
    global_viz.renderSVGElement(text).then(
      svg_elt => encapsulate_and_replace(dot_elt, svg_elt)
    )
    .catch(dot_err => console.error(dot_err));
  });
});

function encapsulate_and_replace(dot_elt, svg_elt) {
  //console.info(dot_elt.textContent);
  var pre_elt = dot_elt.parentNode;
  var root_elt = pre_elt.parentNode;
  var div_elt = document.createElement("div");

  div_elt.classList.add("my-viz-container");
  pre_elt.classList.forEach(t => div_elt.classList.add(t));
  div_elt.appendChild(svg_elt);
  root_elt.replaceChild(div_elt, pre_elt);
}

