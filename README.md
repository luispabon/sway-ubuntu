# Sway builds for Ubuntu 21.10 (amd64)

Ubuntu 21.10 build system for sway and related tools.

Even though most of these tools (including sway and wlroots) are now available in Ubuntu, they move and evolve pretty quickly and I personally prefer to keep up to date with those.

This repository contains a Makefile based build system for all of these. We are NOT building deb packages (see my [old repository which did](https://github.com/luispabon/sway-ubuntu-deb-build) if you want to do so), but we're directly building from source and installing as root (note: there's actually a deb build of GTK 3 to fix some issues with Firefox in 21.10, more info below).

This means you should make sure you do not install any of the ubuntu provided packages, and indeed dependents (for instance other tools that depend on wlroots) should also be compiled here.

Apps provided (make sure you do not install these via Ubuntu's package repos):

  * Sway
  * wlroots
  * seatd
  * clipman
  * kanshi
  * mako
  * nwg-panel
  * swaylock-effects
  * swayimg
  * waybar
  * wdisplays
  * wf-recorder
  * wofi
  * xdg-desktop-portal-wlr (for screen sharing)
  * wayfire / wf-config / wcm
  * wf-shell

Debs:

  * wayland-protocols 1.23  (required for wlroots > 0.14.1 and sway > 1.7)

Deb rebuilds:
  * GTK 3.24.30 with Firefox fixes

## How about older Ubuntus?

There are (unmaintained) branches of this project for earlier versions of Ubuntu. They won't receive any fixes, but if you want to use them and want to send PRs with fixes these are welcome.

## How about the next (still in dev) version of Ubuntu

No reason it won't work. The [debs](debs) files might pose a problem though as they won't be needed beyond Ubuntu 21.10 so make sure you tweak the Makefile not to
install them. The section below on ARM says how to do this (don't follow the instructions on the `.env` file though).

## How about arm (eg Raspberri PI)

We aren't currently using any amd64 hardcoded debs, so arm should work without change.

# Prepare your system's environment

You must make sure that

```
LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu/
```

is set on your environment prior to starting Sway. This is required so that any apps you compile here can find each other's library, as they're placed somewhere else than Ubuntu's default library path.

## Note: LD_LIBRARY_PATH on arm

The value might be completely different. I don't use arm so I can't check. Please let me know if you know via a GitHub issue or a PR to this file.

# Note: `sudo`

Some operations require root to complete. While building `sudo` will be run at some point to do so and your password will be asked.

# Note: `meson` and `ninja`

Make sure you uninstall `meson` and `ninja` if you've already installed them via Ubuntu's package manager. Sway and wlroots routinely require the very latest versions of both, so we'll be installing the latest versions using `python3-pip` instead.

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

## The .env file

You can create an `.env` file and place any overrides to environment variables in there, if you need to. This allows you to for these values in a more permanent and convenient fashion than command line (`make -e FOO=bar ...`) arguments, and without changing the [Makefile](Makefile) which is handy if you need to do a `git pull` on this project. The `.env` file is ignored in source control and as such you need to create it yourself if you need it.

Example syntax:

```
SWAY_VERSION=master
WLROOTS_VERSION=master
SOME_APP_BUILD_MODIFIER_VAR=yes
```

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

# Firefox popup issues (Ubuntu 21.10) & GTK 3.24.30 rebuild

Firefox (94+) have recently reworked their popup handling code, and it does away with all the issues around missing right clicks, add-on popups not opening on certain displays etc. It does require matching fixes on GTK, which will be available upstream from v3.24.31. Ubuntu 21.10 has 3.24.30.

The fixes in question:
  * [https://gitlab.gnome.org/GNOME/gtk/-/merge_requests/3941](https://gitlab.gnome.org/GNOME/gtk/-/merge_requests/3941)
  * [https://gitlab.gnome.org/GNOME/gtk/-/merge_requests/3944](https://gitlab.gnome.org/GNOME/gtk/-/merge_requests/3944)

There's a Makefile target to download gtk's sources, patch them with the above, and re-build the relevant .deb files and install them. First, you need to make sure you enable sources for the main Ubuntu repo, like so:

```
# /etc/apt/sources.list
deb-src http://gb.archive.ubuntu.com/ubuntu/ impish main
```

Then run:

```
make firefox-friendly-gtk
```

And grab a coffee. GTK is a big old chunk of code and takes some time to compile (13 minutes on my i7-7700HQ).

Possible issues:
 * If you get any issues when applying your patches, you can check the error messages - likely, if this is the second time you run this, the patches were already applied and you can just tell patch to ignore the changes
 * If an apt upgrade brought in a newer version of gtk, you'll need to clean up & re-run the build

This is basically the nuclear option that will download sources and apply the patches again from scratch, before re-building again:

```
make firefox-friendly-gtk-clean firefox-friendly-gtk
```

# Screen sharing

Ubuntu 21.10 finally comes with all the plumbing to make it all work:
  * pipewire 0.3
  * xdg-desktop-portal-gtk with the correct build flags


## Limitations

xdg-desktop-portal-wlr does not support window sharing, [only entire outputs](https://github.com/emersion/xdg-desktop-portal-wlr/wiki/FAQ). No way around this. Apps won't show anything on the window list.

## How to install

```
make xdg-desktop-portal-wlr-build -e UPDATE=true
```

This will compile & install & make available the wlr portal to xdg-desktop-portal.

After that, make sure systemd has the following env var `XDG_CURRENT_DESKTOP=sway`. This won't work by merely setting that env var before you start sway. The best way is to create a file containing that at `~/.config/environment.d/xdg.conf`, [like so](https://github.com/luispabon/sway-dotfiles/blob/master/configs/environment.d/xdg.conf). Then reboot.

## Choosing an output to share

When choosing to share a screen from an app, xdpw won't give it a list of available windows or screens to the app to display and for you to choose from. Instead, you'll need to tell your app to share everything and after that the xdpw's output chooser will kick in.

By default it'll be `slurp` - your cursor will change to a crosshairs and you'll be able to click on a screen to share only that one.

The chooser is configurable, see docs here:
https://github.com/emersion/xdg-desktop-portal-wlr/blob/master/xdg-desktop-portal-wlr.5.scd#output-chooser

For instance, if you'd like to use wofi/dmenu, place the following on `~/config/xdg-desktop-portal-wlr/config`

```
[screencast]
chooser_type=dmenu
chooser_cmd=wofi --show=dmenu
```

The actual defaults (if you had no config file) are:

```
[screencast]
chooser_type=simple
chooser_cmd="slurp -f %o -o"
```

## Firefox

Should work out of the box on Firefox 84+ using the wayland backend.

When you start screensharing, on the dialog asking you what to share tell it to "Use operating system settings" when prompted. After that, the output chooser for xdpw will kick in, as explained on the previous section.

## Chromium

Ubuntu's Chromium snap currently does not seem to have webrtc pipewire support.

## Chrome

Open `chrome://flags` and flip `WebRTC PipeWire support` to `enabled`. Should work after that.

### Note
It looks like this option has disappeared and is not available anymore.

# Known issues
Nothing at the moment.
