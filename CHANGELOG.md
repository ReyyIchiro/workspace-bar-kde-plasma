# Changelog

## 1.1.0-wsb1

### Changes

* Forked upstream `lenonk/virtual-desktop-bar` by Lenon Kitchens and wsdfhjxc as
  **Workspace Bar (Plasma)** (plasmoid id `org.kde.plasma.workspacebar`,
  version `1.1.0-wsb1`, license unchanged: GPL-3.0)
* Support tab now credits the original author by name; the upstream Ko-fi
  link is kept so donations still reach Lenon Kitchens
* `Website` / `BugReportsUrl` in `metadata.json` point at this fork
* Untracked the committed JetBrains `.idea/` project files
* Added workspace-bar style desktop buttons (`WsbIconStrip.qml`): number pill +
  per-desktop window icon strip with soft shadows
* Window icons: click to activate, optional middle-click close, optional per-app
  grouping with window-count badge, dim/desaturate for inactive windows
* New Appearance options: `Show Window Icons And Number`, `Icon Size Mode`,
  `Show Icons Background`, `Legibility Shadows`, `Dim Inactive`,
  `Desaturate Inactive`, `Combine Icons Per App`, `Middle-Click Closes Windows`
* Added `requestCloseWindows()` helper to `TaskManagerUtils.qml`
* Documented user-level build/install (`~/.local`) including the required
  `QML_IMPORT_PATH` registration of the C++ QML plugin

### Performance

* The Appearance tab no longer enumerates system fonts on load. The custom-font
  dropdown previously called `Qt.fontFamilies()` in `Component.onCompleted`,
  which costs ~45-90 ms on systems with 1000+ installed font families and
  built a 1000-entry JS array even when the dropdown was never opened. The
  list is now built on `popup.onAboutToShow` (the first time the dropdown is
  actually opened) and the stored font is re-selected once the model exists
* `HintIcon.qml` no longer imports `Qt5Compat.GraphicalEffects`,
  `"../common" as UICommon` or `"../"`. None of them were used by that file,
  but `import "../"` pulled the whole `contents/ui` directory (including the
  applet entry point) into the KCM dialog's import graph on every config tab
  load
* Also fixes a latent crash: the "Custom font" checkbox indexed
  `combo.model[currentIndex].value` directly, which throws if the model is
  empty

## Git

### Changes

* Added an option to specify the thickness of lines used as indicators
* Fixed broken window detection (e.g. Steam or Spotify were affected by this)
* Fixed an issue of not being able to select the Number style under certain conditions
* Updated some configuration dialog elements to be scalable on HiDPI screens

## 1.4

### Changes

* Fixed broken Add Desktop context menu option
* Fixed some issues with hidden or squashed desktop buttons
* Fixed annoying button jumping when only one desktop button is visible

## 1.3

### Changes

* Fixed some issues with window names handling again
* Fixed visibility of buttons when both options are checked
* Fixed some issues on Kubuntu 18.04 and distros with older Qt version

## 1.2

### Changes

* Improved handling of window names (no more ugly class names)
* Fixed broken fade-out animation when removing a non-last desktop
* Fixed black always being the initial color in color picker dialogs
* Added an option to change corner radius for the Block indicator style
* Changed the default length limit for desktop labels to 25 characters

## 1.1

### Changes

* Restored the ability to work with window managers other than KWin

## 1.0

This is a release that introduces breaking changes.

IMPORTANT: User settings from previous versions are ignored.

If you decide to update the plasmoid, be prepared for reconfiguration.

### Changes

* Rewritten some parts of the applet for easier maintenance (and failed)
* Removed the shortcut-based API for KWin scripts (it was pretty much useless)
* Merged options related to keeping/removing empty desktops into "dynamic desktops" feature
* Updated configuration dialogs and rearranged some options and sections
* Added configuration dialog hints, e.g. explaining mutually exclusive options and more
* Added an option to only display desktops containing windows
* Added a feature to move desktops by dragging them with the mouse
* Added an option to remove desktops with the mouse wheel click (enabled by default)
* Removed all context menu actions related to the current desktop
* Added per desktop context menu actions (Rename Desktop, Remove Desktop)
* Changed naming of the desktop shortcuts to include a prefix for easier recognition
* Added an option to set common size for all desktop buttons, based on the largest button
* Added an option to filter occupied desktops by monitor (enabled by default)
* Added appearance settings for desktops containing windows needing attention
* Removed some of the existing desktop label styles (they can be recreated)
* Added a desktop label style displaying the name of the active window on a desktop
* Added a custom desktop label style that can be formatted with some variables
* Added options to limit length of desktop labels, and to display them as UPPERCASED
* Fixed some bugs related to distincting and coloring desktop indicators and labels
* Added hover tooltips containing brief information about windows present on a given desktop

## ...
