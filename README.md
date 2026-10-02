# Workspace Bar (Plasma)

A KDE Plasma 6 widget that brings the **GNOME `workspace-bar` look-and-feel** to Plasma: each
virtual desktop is a small pill showing the **desktop number** plus a strip of **window icons**
for the apps running on that desktop — alongside the classic configurable desktop bar features
(desktop switching, indicators, labels, dynamic desktop management).

This is a fork of [lenonk/virtual-desktop-bar](https://github.com/lenonk/virtual-desktop-bar)
by Lenon Kitchens, rebranded as **Workspace Bar (Plasma)** with plasmoid id
`org.kde.plasma.workspacebar`. Both projects are GPL-3.0. The upstream project's desktop
switching, indicators, labels, and dynamic desktop management are preserved unchanged;
this fork adds the window-icon pill rendering described below.

Forked and maintained by Raihan Zaky ([@ReyyIchiro](https://github.com/ReyyIchiro)).

The widget displays desktops as labeled buttons with configurable indicators, styling, and behavior options. It also supports optional dynamic desktop management to automatically maintain a spare empty desktop.

---

## Screenshots

### Adding, renaming, moving, and removing a desktop:
![Example 1](screenshots/1.gif)

### Various desktop label styles:
![Example 1](screenshots/2.gif)

### Various desktop indicator styles:
![Example 1](screenshots/3.gif)

### Partial support for vertical panels (still a work in progress):
![Example 1](screenshots/4.png)

*(Screenshots may change as the widget evolves.)*

---

## Features

### Desktop Switching
- Displays desktops as labeled buttons instead of thumbnails
- Quickly switch desktops with a click
- Optional scroll-wheel desktop switching
- Optional filtering by screen

### Workspace-Bar Style (GNOME workspace-bar look)
Each desktop button can render as a "pill" (configurable via the Appearance tab):

- **Number pill** — the desktop number, highlighted for the current desktop
- **Window icon strip** — one icon per app running on that desktop
  - Left-click an icon to activate its window
  - Middle-click an icon to close its windows (optional)
  - Optional per-app grouping with a window-count badge (`Combine Icons`)
  - Optional dimming (`Dim Inactive`) and desaturation (`Desaturate Inactive`) of inactive windows
  - Optional translucent pill background and soft legibility shadows
  - Icon size follows `Icon Size Mode` (Small = 16 px, Normal = 20 px, Large = 24 px)
- The strip updates automatically as windows open/close/move between desktops

The legacy label + indicator rendering remains available by disabling
`Show Window Icons And Number` in the Appearance tab.

### Indicator Styles
Multiple indicator styles are available:

- Edge line
- Side line
- Block
- Rounded block
- Full-size highlight

Indicator thickness, radius, colors, and behavior are configurable.

### Label Customization
Desktop labels support:

- Multiple label styles
- Custom formatting
- Maximum length limits
- Uppercase option
- Bold current desktop
- Dim inactive desktops
- Custom fonts and sizes
- Custom label colors

### Appearance Controls
- Adjustable button spacing and margins
- Optional uniform button sizing
- Configurable animations
- Add-desktop button support

### Dynamic Desktop Management
Optionally:
- Automatically maintain one empty desktop
- Create desktops as needed
- Remove unused desktops
- Optionally switch or rename newly created desktops
- Execute commands when desktops are created

---

## Installation (user-level, no sudo)

It installs entirely under `$HOME`, so no root/sudo is required. Build artifacts are not published to any distro repository — only the source repo here.

### Requirements

- KDE Plasma 6 (Qt 6 / KF6) on Wayland
- `qt6-5compat-graphicaleffects` (ships with Qt on most distros — used for pill shadows)

### Build and install

```sh
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX="$HOME/.local"
cmake --build build -j"$(nproc)"
cmake --install build
```

This installs the plasmoid to `~/.local/share/plasma/plasmoids/org.kde.plasma.workspacebar/`
and a small **C++ QML plugin** to `~/.local/lib/qml/org/kde/plasma/virtualdesktopbar/`.

### Register the QML plugin (required for local installs)

Qt only searches system QML paths by default, so the plugin under `~/.local/lib/qml` must be
exported. Create `~/.config/environment.d/95-qml-import-path.conf`:

```
QML_IMPORT_PATH=/home/YOUR_USER/.local/lib/qml
```

Then restart the session (or just the shell):

```sh
systemctl --user restart plasma-plasmashell.service
```

> On Qt 6 the variable is `QML_IMPORT_PATH` (`QML2_IMPORT_PATH` also works as a legacy alias).
> Without this step the widget fails with `module "org.kde.plasma.virtualdesktopbar" is not installed`
> (shown as `Type Common.Backend unavailable`).

### Add it to a panel

Use Plasma's widget explorer (*Add Widgets → Workspace Bar (Plasma)*), or run:

```sh
gdbus call --session --dest org.kde.plasmashell --object-path /PlasmaShell \
  --method org.kde.PlasmaShell.evaluateScript \
  'var ps = panels(); for (var i = 0; i < ps.length; i++) { if (ps[i].location === "top") { ps[i].addWidget("org.kde.plasma.workspacebar"); break; } }'
```

Then drag the widget to the position you want (e.g. far left, like GNOME's Activities area)
via *right-click panel → Edit Mode*.

### Rebuilding after changes

```sh
cmake --build build -j"$(nproc)" && cmake --install build
systemctl --user restart plasma-plasmashell.service   # reload QML/plugin
```

---

## Usage

1. Add **Workspace Bar (Plasma)** to a panel or desktop.
2. Open widget settings to configure appearance and behavior.
3. Customize indicator styles, labels, colors, and dynamic desktop options to your liking.

---

## Compatibility

This widget is designed and tested for:

- KDE Plasma 6
- Wayland sessions

Wayland is required.

---

## Known Issues

Some Plasma panel visibility modes currently interfere with virtual desktop widgets. If desktops do not update correctly:

- Avoid panel modes that hide the panel automatically, or
- Use standard visibility modes.

Upstream Plasma behavior may change in future releases.

---

## Contributing

Bug reports, suggestions, and pull requests are welcome.

If reporting an issue, please include:
- Plasma version
- Distribution
- Steps to reproduce the problem

---

## License

This project is distributed under the **GPL-3.0**, inherited from upstream
[virtual-desktop-bar](https://github.com/lenonk/virtual-desktop-bar). The full license text is in
[`LICENSE`](LICENSE). This remains a GPL work: any redistribution, modified or unmodified, must
carry the same license and attribution.

---

## Acknowledgements

- **[Lenon Kitchens](https://github.com/lenonk) / [wsdfhjxc](https://github.com/wsdfhjxc)** —
  authors of **[lenonk/virtual-desktop-bar](https://github.com/lenonk/virtual-desktop-bar)**, the
  upstream widget this project is forked from: desktop switching, indicators, labels, dynamic
  desktop management, and the Plasma 6 port. Their Ko-fi donation page is still linked in the
  widget's Support tab — please consider supporting them there.
- **GNOME `workspace-bar` / workspace-bar style panels** — the visual design of the
  number pill + per-desktop window icon strip reproduced by `WsbIconStrip.qml`.
- The KDE Plasma and KDE Frameworks teams.

The upstream git history is preserved in this repository so the fork relationship stays
verifiable. Internal module names (the `virtualdesktopbar` QML plugin) are left unchanged from
upstream on purpose.

---
## Support

Fork-specific bugs: https://github.com/ReyyIchiro/workspace-bar-kde-plasma/issues
Upstream issues (unchanged behaviour): https://github.com/lenonk/virtual-desktop-bar/issues

Donations go to the original author, Lenon Kitchens:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/K3K51TO6S1)

