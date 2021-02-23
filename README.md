# Sway builds for Ubuntu 21.04

Ubuntu 21.04 build system for sway and related tools.

Even though most of these tools (including sway and wlroots) are now available in Ubuntu, they move and evolve pretty quickly and I personally prefer to keep up to date with those.

This repository contains a Makefile based build system for all of these. We are NOT building deb packages (see my [old repository which did](https://github.com/luispabon/sway-ubuntu-deb-build) if you want to do so), but we're directly building from source and installing as root.

This means you should make sure you do not install any of the ubuntu provided packages, and indeed dependents (for instance other tools that depend on wlroots) should also be compiled here.

Apps provided (make sure you do not install these via Ubuntu's package repos):

  * Sway
  * wlroots
  * clipman
  * kanshi
  * mako
  * swaylock-effects
  * waybar
  * wf-recorder
  * wofi
  * xdg-desktop-portal-wlr (for screen sharing)

Debs:

  * network-manager-gnome: supersedes Ubuntu hirsute's version, hides unmanaged interfaces (eg virtualbox, docker, etc)

# Prepare your system's environment

You must make sure that

```
LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu/
```

is set on your environment prior to starting Sway. This is required so that any apps you compile here can find each other's library, as they're placed somewhere else than Ubuntu's default library path.

# Note: `sudo`

Some operations require root to complete. While building `sudo` will be run at some point to do so and your password will be asked.

# Note: `meson` and `ninja`

Make sure you uninstall `meson` and `ninja` if you've already installed them via Ubuntu's package manager. We need newer versions than what's available in 20.10 and we'll be installing the latest versions using `pip` instead.

# Dependencies

You need `make`. That's it really, everything else can be installed via the provided targets in the [Makefile](Makefile).

# Building stuff

First time, you should probably run

```
make yolo
```

This will clone all the app's git repos, install dev dependencies and tools required to build everything, then it proceeds to build each project in sequence.

Have a look at the [Makefile](Makefile) for all the different build targets, in case you want to build this or the other app. I for instance build `wlroots` and `sway` once a week, for which I have

```
make core
```

If you just want to update the apps (not wlroots and sway):

```
make apps
```

## Updating repositories before building

Simply pass `-e UPDATE=true` to `make`:

```
make mako -e UPDATE=true
```

## App versions

At the top of the [Makefile](Makefile) you'll see one variable per app that defines which version of that app to build that you can override via environment. By version, I mean either a git hash, or a branch, or a tag - we will simply be running `git checkout $APP_VERSION` before building that app.

For instance, if I wanted to build wlroots `0.11.0`, sway `1.5` and swaylock-effects `master`, while making sure we're on the absolute latest commits for each:

```
make core swaylock-build -e SWAY_VERSION=1.5 -e WLROOTS_VERSION=0.11.0 -e UPDATE=true
```

Note the lack of `SWAYLOCK_VERSION` up there - `master` is already the default.

# Uninstalling stuff

When installing the stuff we're compiling, `ninja` will be copying the relevant files wherever they need to be in the system, without creating a `deb` package. Therefore, `apt autoremove app` won't work.

So far all the apps in the repo except for clipman use `meson` and `ninja` for building. As long as you don't delete the `APP/build` repository you can uninstall from the system anything ninja installs:

```
cd APP
sudo ninja -C build uninstall
```

If you deleted the `build` folder on the app, simply build the app again before running the command above.

# wlroots dependencies

This goes without saying, but if you're updating `wlroots` make sure it's built first so that any of the other apps that link against it (like `sway`) have the right version to link against instead of linking against the version you're replacing.

# Screen sharing

Ubuntu 21.04 finally comes with all the plumbing to make it all work:
  * pipewire 0.3
  * xdg-desktop-portal-gtk with the correct build flags


## Limitations

xdg-desktop-portal-wlr does not support window sharing, [only entire outputs](https://github.com/emersion/xdg-desktop-portal-wlr/wiki/FAQ). No way around this. Apps won't show anything on the window list.

## How to install

```
make xdg-desktop-portal-wlr -e UPDATE=true
```

This will compile & install & make available the wlr portal to xdg-desktop-portal.

After that, make sure you add the following to your sway config:

```
exec /usr/libexec/xdg-desktop-portal -r
```

For some reason, even though xdg-desktop-portal does init by itself, it might be doing it too early to catch on the fact we're running sway and won't try to automatically start the wlr portal when needed.

## Firefox

Should work out of the box on Firefox 84+ using the wayland backend. There's no list of windows, so you need to tell it to share your entire screen when prompted.

## Chromium

Ubuntu's Chromium snap currently does not seem to have webrtc pipewire support.

## Chrome

Open `chrome://flags` and flip `WebRTC PipeWire support` to `enabled`. Should work after that.


Open `chrome://flags`
# Known issues
## Can't copy paste from Firefox address bar

See https://github.com/swaywm/wlroots/issues/2421

The change has already been made to sway via commit [5ad3990a6c9beae44392e1962223623c0a4e3fa9](https://github.com/swaywm/sway/commit/5ad3990a6c9beae44392e1962223623c0a4e3fa9) [(this pull request)](https://github.com/swaywm/sway/pull/5788).

Long story short, this will cease to be an issue as long as you're using gtk >=3.24.24, which will be the case from ubuntu hirsute.

Fix: revert this change on your local sway checkout:

```
cd sway
git revert 5ad3990a6c9beae44392e1962223623c0a4e3fa9
```

You can get a clean copy of sway after you upgrade to ubuntu hirsute.

## Can't compile latest master on wlroots and sway

Indeed. You can see I've set `SWAY_VERSION` and `WLROOTS_VERSION` on the Makefile to a certain commit hash each. Unfortunately these are the latest versions that will compile cleanly with Ubuntu Focal and Ubuntu Groovy, as versions after that require libwayland-server0 >=1.19. This is a crucial system library and can't be cleanly updated on these versions of ubuntu without upsetting hundreds of other packages.

You might be able to cherry-pick certain commits for fixes or whatever on your local checkouts of wlroots and sway. Just make sure you create a branch for these from the commits on the Makefile, do your picks there, and tweak `SWAY_VERSION` and `WLROOTS_VERSION` to use that branch.
