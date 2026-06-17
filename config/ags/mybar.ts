// mybar.ts – custom entry to launch the Material‑You bar
import app from "ags/gtk4/app";
import style from "./style.scss";
import Bar from "./Bar";

app.start({
  css: style,
  main() {
    // Directly add the Bar widget as the root window
    // `Bar` returns a Window component
    Bar();
  },
});
