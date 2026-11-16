// "Rex Open" droplet: hands files from Finder or `open -a "Rex Open" FILE...` to
// ~/.config/rex/rex-open.sh, which does the work, so editing that needs no rebuild.
// Rebuild only when this stub changes, then commit the app (mise links it into ~/Applications):
//   osacompile -l JavaScript -o ~/.dotfiles/rex/Rex\ Open.app ~/.config/rex/rex-open.js

const app = Application.currentApplication();
app.includeStandardAdditions = true;
const q = (s) => "'" + s.replace(/'/g, "'\\''") + "'";

function go(paths) {
  const script = app.systemAttribute("HOME") + "/.config/rex/rex-open.sh";
  try {
    app.doShellScript(["/bin/sh", script, ...paths].map(q).join(" "));
  } catch (e) {
    app.displayAlert("Rex Open failed", { message: String(e) });
  }
}

function openDocuments(docs) {
  go(docs.map((d) => d.toString()));
}

function run() {
  go([]);
}
