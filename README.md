# Sway builds for Ubuntu 24.04 (amd64)

Ubuntu 24.04 build system for sway and related tools.

Even though most of these tools (including sway and wlroots) are now available in Ubuntu, they move and evolve pretty quickly and I prefer to keep up to date with those.

This repository contains a Makefile-based build system for all of these. We are NOT building deb packages (see my [old repository which did](https://github.com/luispabon/sway-ubuntu-deb-build) if you want to do so), but we're directly building from source and installing as root.

## Note: upgrading from Ubuntu 22.10 or earlier

You can safely ignore this note if this is the first time you're installing Sway and all the other apps from this repo.

 * **Wofi** has been removed from our install targets as it's now semi-abandoned. It is, however, available to install from Ubuntu's repos via `apt install wofi` if you need it. Make sure you clean the compiled version up from the system:
      ```shell
        cd wofi
        sudo ninja -C build uninstall
      ```

 * Python's pip is now refusing to install global packages and instead recommending to use pipx to do so. I have migrated all such installs to pipx, but it means you need to clean up `meson` and `ninja`:
    ```shell
      sudo pip3 uninstall meson ninja --break-system-packages
    ```
 * After cleaning up meson and ninja, you need to install dependencies again as there are new ones, including meson and ninja. Run `make yolo -e UPDATE=true` to do so but also re-compile everything with the new base libraries.

## Apps provided

A lot of these have actual Ubuntu packages now, however, it is possible to install them at the same time as the versions you compile from here. System packages typically go to the `/usr/` prefix and manually compiled ones to `/usr/local`, so it is a matter of setting up your shell's path correctly (giving preference to `/usr/local/bin` over `/usr/bin` or `/bin`) as well as `LD_LIBRARY_PATH` (see note below).

**Core:**
  * Sway
  * wlroots
  * seatd

**Apps:**
  * clipman
  * kanshi
  * mako
  * nwg-panel
  * rofi (wayland fork)
  * swaylock-effects
  * swayimg
  * waybar
  * wdisplays
  * wf-recorder
  * xdg-desktop-portal-wlr (for screen sharing)

**Wayfire apps:**
  * wayfire / wf-config / wcm
  * wf-shell

**Debs:**
  * wayland-protocols 1.35
  * libinput 1.26
  * libdrm 2.4.122

### How about older Ubuntus?

There are (unmaintained) branches of this project for earlier versions of Ubuntu. They won't receive any fixes unless contributed by the community, as I have moved on from using them. PRs more than welcome.

I usually switch to the next Ubuntu a few weeks before release, so typically old branches will have the very latest versions of the apps that are physically compilable given the libraries available.

### How about the next (still in dev) version of Ubuntu

No reason it won't work. The [debs](debs) files (if any) might pose a problem though as they are typically backported from the next Ubuntu version into the current when needed, and won't be needed on the next version, so make sure you tweak the Makefile not to install them.

### How about arm (eg Raspberry PI)

There are some arch-specific packages in `debs/` so make sure you don't try to install these and instead use `apt download` from a docker container of a newer version of Ubuntu to download them.

## Prepare your system's environment

You must make sure that

```
LD_LIBRARY_PATH=/usr/local/lib/x86_64-linux-gnu/
```
or
```
LD_LIBRARY_PATH=/usr/local/lib/aarch64-linux-gnu/
```

is set on your environment before starting Sway. This is required so that any apps you compile here can find each other's library, as they're placed somewhere else than Ubuntu's default library path.

### Note: `sudo`

Some operations require root to complete - typically anything that requires access to `/usr/local/`. See [Makefile](Makefile) for details.

While building, `sudo` will be run at some point to do so, and your password will be asked.

### Note: `meson` and `ninja`

Make sure you uninstall `meson` and `ninja` if you've already installed them via Ubuntu's package manager. Sway and wlroots routinely require the very latest versions of both, so we'll be installing the latest versions using `pipx` instead.

## Dependencies

 * `git`
 * `lsb-release`
 * `make`
 * `sudo `

Everything else can be installed via the provided targets in the [Makefile](Makefile).

## Building stuff

The first time, you should probably run

```
make yolo
```

This will clone all the app's git repos, install dev dependencies and tools required to build everything, then it proceeds to build each project in sequence.

Have a look at the [Makefile](Makefile) for all the different build targets, in case you want to build this or the other app. I for instance build `wlroots` and `sway` once a week, for which I have

```
make core
```

If you just want to update the apps (not wlroots and Sway):

```
make apps
```

### Updating repositories before building

Simply pass `-e UPDATE=true` to `make`:

```
make mako -e UPDATE=true
```

### App versions

At the top of the [Makefile](Makefile) you'll see one variable per app that defines which version of that app to build that you can override via environment. By version, I mean either a git hash, a branch, or a tag - we will simply be running `git checkout $APP_VERSION` before building that app.

For instance, if I wanted to build wlroots `0.11.0`, sway `1.5` and swaylock-effects `master` while making sure we're on the absolute latest commits for each:

```
make core swaylock-build -e SWAY_VERSION=1.5 -e WLROOTS_VERSION=0.11.0 -e UPDATE=true
```

Note the lack of `SWAYLOCK_VERSION` up there - `master` is already the default.

### The .env file

You can create a `.env` file and place any overrides to environment variables in there if you need to. This allows you to for these values more permanently and conveniently than the command line (`make -e FOO=bar ...`) arguments, and without changing the [Makefile](Makefile) which is handy if you need to do a `git pull` on this project. The `.env` file is ignored in source control and as such you need to create it yourself if you need it.

Example syntax:

```
SWAY_VERSION=master
WLROOTS_VERSION=master
SOME_APP_BUILD_MODIFIER_VAR=yes
```

## Uninstalling stuff

When installing the stuff we're compiling, `ninja` will be copying the relevant files wherever they need to be in the system, without creating a `deb` package. Therefore, `apt autoremove app` won't work.

So far all the apps in the repo except for clipman use `meson` and `ninja` for building. As long as you don't delete the `APP/build` repository you can uninstall from the system anything ninja installs:

```
cd APP
sudo ninja -C build uninstall
```

If you deleted the `build` folder on the app, simply build the app again (on the same version as before) before running the command above.

## wlroots & seatd dependencies

This goes without saying, but if you're updating `wlroots` or `seatd` make sure they're built first (`seatd`, then `wlroots`) so that any of the other apps that link against it (like `sway`) have the right version to link against instead of linking against the version you're replacing.

## Screen sharing

Ubuntu 24.04 comes with all the plumbing to make it all work:
  * pipewire 0.3
  * wireplumber
  * xdg-desktop-portal-gtk with the correct build flags

### Limitations

xdg-desktop-portal-wlr does not support window sharing, [only entire outputs](https://github.com/emersion/xdg-desktop-portal-wlr/wiki/FAQ). No way around this. Apps won't show anything on the window list when asked to initiate a screen-sharing session.

### How to install

```
make xdg-desktop-portal-wlr-build -e UPDATE=true
```

This will compile & install & make available the wlr portal to xdg-desktop-portal.

After that, make sure systemd has the following env var `XDG_CURRENT_DESKTOP=sway`. This won't work by merely setting that env var before you start sway. The best way is to create a file containing that at `~/.config/environment.d/xdg.conf`, [like so](https://github.com/luispabon/sway-dotfiles/blob/master/configs/environment.d/xdg.conf). Then reboot.

### Choosing an output to share

When choosing to share a screen from an app, xdpw won't give it a list of available windows or screens for the app to display and for you to choose from. Instead, you'll need to tell your app to share everything and after that, the xdpw's output chooser will kick in.

By default it'll be `slurp` - your cursor will change to crosshairs (`✛`) and you'll be able to click on a screen to share only that one.

The chooser is configurable, see docs here:
https://github.com/emersion/xdg-desktop-portal-wlr/blob/master/xdg-desktop-portal-wlr.5.scd#output-chooser

For instance, if you'd like to use rofi/dmenu, place the following on `~/config/xdg-desktop-portal-wlr/config`

```
[screencast]
chooser_type=dmenu
chooser_cmd=rofi -dmenu
```

The actual defaults (if you had no config file) are:

```
[screencast]
chooser_type=simple
chooser_cmd="slurp -f %o -o"
```

### Firefox

Should work out of the box on Firefox 84+ using the wayland backend.

When you start screen sharing, on the dialog asking you what to share tell it to "Use operating system settings" when prompted. After that, the output chooser for xdpw will kick in, as explained in the previous section.

### Chromium & Chrome

It should work out of the box when using the wayland backend, but if it doesn't open `chrome://flags` and ensure `WebRTC PipeWire support` is `enabled`.
