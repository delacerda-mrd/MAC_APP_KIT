var src = readFile("src/app.jsx");
try {
  print(Babel.transform(src, { presets: [["react", { runtime: "classic" }]] }).code);
} catch (e) {
  debug ? debug(e.message) : 0;
  quit(1);
}
