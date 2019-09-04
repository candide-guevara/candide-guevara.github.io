// Looks for all elements with dot code and calls viz.js on them to generate an svg.

document.addEventListener('DOMContentLoaded', function(event) {
  var viz = new Viz();
  document.querySelectorAll("pre > code.language-myviz").forEach(function(dot_elt) {
    var text = dot_elt.textContent;
    viz.renderSVGElement(text).then(function(svg_elt) {
      encapsulate_and_replace(dot_elt, svg_elt);
    })
    .catch(function(dot_err) { console.error(dot_err); });
  });
});

function encapsulate_and_replace(dot_elt, svg_elt) {
  var pre_elt = dot_elt.parentNode;
  var root_elt = pre_elt.parentNode;
  var div_elt = document.createElement("div");

  div_elt.className = "my-viz-container";
  div_elt.appendChild(svg_elt);
  root_elt.replaceChild(div_elt, pre_elt);
}

