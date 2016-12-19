# Removes bogus spacing between letters

BEGIN {
  STATE_LOOKING = 0;
  REMOVE_CLIP_PATHS = 0;

  FONT_SIZE_START = "------2.7";
  FONT_SIZE_WANTED = "------2.8";
  FONT_COLOR_START = "#000000";
  FONT_COLOR_WANTED = "#888a85";
}

/<text/ {
  STATE_LOOKING = 1;
}

STATE_LOOKING && /x="0/ {
  sub (/x="[^"]+"/, "x=\"0\"");
}

STATE_LOOKING && /font-size:/ {
  sub ("font-size:" FONT_SIZE_START "[[:digit:]]*", "font-size:" FONT_SIZE_WANTED);
}

STATE_LOOKING && /fill:/ {
  sub ("fill:" FONT_COLOR_START, "fill:" FONT_COLOR_WANTED);
}

/<\/text/ {
  STATE_LOOKING = 0;
}

# Replace even if not inside a text element

REMOVE_CLIP_PATHS && /clip-path/ {
  sub (/clip-path="[^"]+"/, "");
}

{ print ($0); }

