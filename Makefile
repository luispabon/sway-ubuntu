REQUIRED_UBUNTU_CODENAME=mantic
CURRENT_UBUNTU_CODENAME=$(shell lsb_release -cs)

# Include environment overrides
ifneq ("$(wildcard .env)","")
	include .env
	export
endif

# Define here which branches or tags you want to build for each project

# Nearly the newest at Nov 21st, highest buildable on regular ubuntu 23.10 without updating libdrm (a requirement of wlroots >= 0.18.0)

SWAY_VERSION ?= master
WLROOTS_VERSION ?= master

SEATD_VERSION ?= master
LIBVARLINK_VERSION ?= master
LIBSCFG_VERSION ?= master
KANSHI_VERSION ?= master
WAYBAR_VERSION ?= master
SWAYLOCK_VERSION ?= master
MAKO_VERSION ?= master
WF_RECORDER_VERSION ?= master
CLIPMAN_VERSION ?= master
SWAYIMG_VERSION ?= master
WDISPLAYS_VERSION ?= master
XDG_DESKTOP_PORTAL_WLR_VERSION ?= master
NWG_PANEL_VERSION ?= master
WAYFIRE_VERSION ?= master
WF_CONFIG_VERSION ?= master
WF_SHELL_VERSION ?= master
WCM_VERSION ?= master
ROFI_WAYLAND_VERSION ?= wayland

ifdef UPDATE
	UPDATE_STATEMENT = git pull && git submodule update --init &&
endif

ifdef ASAN_BUILD
	ASAN_STATEMENT = -Db_sanitize=address
endif

define BASE_CLI_DEPS
	git \
	pipx
endef

define WLROOTS_DEPS
	wayland-protocols \
	libwayland-dev \
	libegl1-mesa-dev \
	libgles2-mesa-dev \
	libdrm-dev \
	libgbm-dev \
	libinput-dev \
	libxkbcommon-dev \
	libgudev-1.0-dev \
	libpixman-1-dev \
	libsystemd-dev \
	hwdata \
	cmake \
	libpng-dev \
	libavutil-dev \
	libavcodec-dev \
	libavformat-dev \
	libdisplay-info-dev \
	libliftoff-dev \
	libxcb-composite0-dev \
	libxcb-icccm4-dev \
	libxcb-image0-dev \
	libxcb-render0-dev \
	libxcb-xfixes0-dev \
	libxkbcommon-dev \
	libxcb-xinput-dev \
	libx11-xcb-dev \
	libxcb-dri3-dev \
	libxcb-res0-dev
endef

define SWAY_DEPS
	libjson-c-dev \
	libpango1.0-dev \
	libcairo2-dev \
	libgdk-pixbuf2.0-dev \
	scdoc \
	xwayland
endef

define GTK_LAYER_DEPS
	libgtk-layer-shell-dev \
	libgtk-layer-shell0
endef

define WAYBAR_BUILD_DEPS
	libgtkmm-3.0-dev \
	libjsoncpp-dev \
	libfmt-dev \
	libpulse-dev \
	libnl-3-dev \
	libnl-genl-3-dev \
	libappindicator-dev \
	libdbusmenu-gtk3-dev \
	libsndio-dev \
	libmpdclient-dev \
	libxkbregistry-dev
endef

define WAYBAR_RUNTIME_DEPS
	libgtkmm-3.0-1v5 \
	libspdlog1.10 \
	libjsoncpp25 \
	libnl-3-200 \
	libnl-genl-3-200 \
	libspdlog-dev \
	libwireplumber-0.4-dev \
	libdbusmenu-gtk3-4
endef

define SWAYLOCK_DEPS
	libpam0g-dev
endef

define WF_RECORDER_DEPS
	libswscale-dev \
	libavdevice-dev \
	ocl-icd-opencl-dev \
	opencl-c-headers
endef

define SWAYIMG_DEPS
	libjpeg-dev \
	librsvg2-dev \
	libwebp-dev \
	libavif-dev \
	libgif-dev
endef

define CLIPMAN_DEPS
	golang-go
endef

define XDG_DESKTOP_PORTAL_DEPS
	libpipewire-0.3-dev \
	libinih-dev \
	xdg-desktop-portal \
	xdg-desktop-portal-dev
endef

define WDISPLAYS_DEPS
	scour
endef

define NWG_PANEL_DEPS
	libgirepository1.0-dev \
	light \
	python3-cairo-dev \
	python3-dev \
	python3-i3ipc \
	python3-pyalsa \
	python3-setuptools
endef

define WAYFIRE_DEPS
	doctest-dev \
	libglm-dev \
	libxml2-dev
endef

define ROFI_WAYLAND_DEPS
	libxcb-xkb-dev \
	libxcb-ewmh-dev \
	libxcb-randr0-dev \
	libxcb-cursor-dev \
	libxcb-xinerama0-dev \
	libxcb-util-dev \
	libstartup-notification0-dev \
	flex \
	bison \
	libxkbcommon-x11-dev
endef

define PIP_PACKAGES
	ninja \
	meson
endef

NINJA_CLEAN_BUILD_INSTALL=$(UPDATE_STATEMENT) sudo ninja -C build uninstall; sudo rm build -rf && meson build $(ASAN_STATEMENT) && ninja -C build && sudo ninja -C build install

PIPX_ENV=PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin

check-ubuntu-version:
	@if [ "$(CURRENT_UBUNTU_CODENAME)" != "$(REQUIRED_UBUNTU_CODENAME)" ]; then echo "### \n#  Unsupported version of ubuntu (current: '$(CURRENT_UBUNTU_CODENAME)', required: '$(REQUIRED_UBUNTU_CODENAME)').\n#  Check this repo's remote branches (git branch -r) to see if your version is there and switch to it (these branches are deprecated but should work for your version)\n###"; exit 1; fi

## Meta installation targets
yolo: install-dependencies install-repos core apps
core: seatd-build wlroots-build sway-build
apps: grimshot-install xdg-desktop-portal-wlr-build kanshi-build waybar-build swaylock-build mako-build rofi-wayland-build wf-recorder-build clipman-build nwg-panel-install swayimg-build wdisplays-build
wf: wf-config-build wayfire-build wf-shell-build wcm-build

## Build dependencies
install-repos:
	@git clone https://github.com/swaywm/sway.git || echo "Already installed"
	@git clone https://github.com/OctopusET/sway-contrib.git || echo "Already installed"
	@git clone https://gitlab.freedesktop.org/wlroots/wlroots.git || echo "Already installed"
	@git clone https://git.sr.ht/~emersion/kanshi || echo "Already installed"
	@git clone https://github.com/varlink/libvarlink.git || echo "Already installed"
	@git clone https://git.sr.ht/~emersion/libscfg || echo "Already installed"
	@git clone https://github.com/Alexays/Waybar.git || echo "Already installed"
	@git clone https://github.com/jirutka/swaylock-effects.git || echo "Already installed"
	@git clone https://github.com/emersion/mako.git || echo "Already installed"
	@git clone https://github.com/ammen99/wf-recorder.git || echo "Already installed"
	@git clone https://github.com/luispabon/clipman.git || echo "Already installed"
	@git clone https://github.com/emersion/xdg-desktop-portal-wlr.git || echo "Already installed"
	@git clone https://github.com/luispabon/wdisplays.git || echo "Already installed"
	@git clone https://github.com/nwg-piotr/nwg-panel.git || echo "Already installed"
	@git clone https://github.com/WayfireWM/wf-config.git || echo "Already installed"
	@git clone https://github.com/WayfireWM/wayfire.git || echo "Already installed"
	@git clone https://github.com/WayfireWM/wf-shell.git || echo "Already installed"
	@git clone https://github.com/WayfireWM/wcm.git || echo "Already installed"
	@git clone https://git.sr.ht/~kennylevinsen/seatd || echo "Already installed"
	@git clone https://github.com/artemsen/swayimg.git || echo "Already installed"
	@git clone https://github.com/sardemff7/libgwater.git || echo "Already installed"
	@git clone https://github.com/lbonn/rofi.git || echo "Already installed"

install-dependencies: debs-install install-pip-packages
	sudo apt -y install --no-install-recommends \
		$(BASE_CLI_DEPS) \
		$(WLROOTS_DEPS) \
		$(SWAY_DEPS) \
		$(GTK_LAYER_DEPS) \
		$(WAYBAR_BUILD_DEPS) \
		$(WAYBAR_RUNTIME_DEPS) \
		$(SWAYLOCK_DEPS) \
		$(WF_RECORDER_DEPS) \
		$(CLIPMAN_DEPS) \
		$(SWAYIMG_DEPS) \
		$(WDISPLAYS_DEPS) \
		$(WAYFIRE_DEPS) \
		$(NWG_PANEL_DEPS) \
		$(ROFI_WAYLAND_DEPS) \
		$(XDG_DESKTOP_PORTAL_DEPS)

	sudo apt -y install build-essential

install-pip-packages:
	# From 23.04, python3-pip refuses to install packages globally and recommends pipx for that instead
	echo $(PIP_PACKAGES) | xargs -n 1 sudo $(PIPX_ENV) pipx install
	echo $(PIP_PACKAGES) | xargs -n 1 sudo $(PIPX_ENV) pipx upgrade

debs-install: check-ubuntu-version
	sudo dpkg -i debs/*.deb || sudo apt -fy install

clean-dependencies:
	sudo apt autoremove --purge $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(WAYBAR_DEPS) $(SWAYLOCK_DEPS) $(WF_RECORDER_DEPS) $(WDISPLAYS_DEPS) $(XDG_DESKTOP_PORTAL_DEPS)

meson-ninja-build: check-ubuntu-version
	cd $(APP_FOLDER) && git fetch && git checkout $(APP_VERSION) && $(NINJA_CLEAN_BUILD_INSTALL)

## Sway
seatd-build:
	make meson-ninja-build -e APP_FOLDER=seatd -e APP_VERSION=$(SEATD_VERSION)

wlroots-build:
	make meson-ninja-build -e APP_FOLDER=wlroots -e APP_VERSION=$(WLROOTS_VERSION)

sway-build:
	make meson-ninja-build -e APP_FOLDER=sway -e APP_VERSION=$(SWAY_VERSION)

## Libs
libvarlink-build:
	make meson-ninja-build -e APP_FOLDER=libvarlink -e APP_VERSION=$(LIBVARLINK_VERSION)

libscfg-build:
	make meson-ninja-build -e APP_FOLDER=libscfg -e APP_VERSION=$(LIBSCFG_VERSION)

## Apps
grimshot-install:
	sudo cp -f sway-contrib/grimshot /usr/local/bin/

kanshi-build: libvarlink-build libscfg-build
	make meson-ninja-build -e APP_FOLDER=kanshi -e APP_VERSION=$(KANSHI_VERSION)

waybar-build:
	make meson-ninja-build -e APP_FOLDER=Waybar -e APP_VERSION=$(WAYBAR_VERSION)

swaylock-build:
	make meson-ninja-build -e APP_FOLDER=swaylock-effects -e APP_VERSION=$(SWAYLOCK_VERSION)
	sudo chmod a+s /usr/local/bin/swaylock

mako-build:
	make meson-ninja-build -e APP_FOLDER=mako -e APP_VERSION=$(MAKO_VERSION)

wf-recorder-build:
	make meson-ninja-build -e APP_FOLDER=wf-recorder -e APP_VERSION=$(WF_RECORDER_VERSION)

wdisplays-build:
	make meson-ninja-build -e APP_FOLDER=wdisplays -e APP_VERSION=$(WDISPLAYS_VERSION)

rofi-wayland-build:
	make meson-ninja-build -e APP_FOLDER=libgwater
	make meson-ninja-build -e APP_FOLDER=rofi -e APP_VERSION=$(ROFI_WAYLAND_VERSION)

clipman-build:
	cd clipman; git fetch; git checkout $(CLIPMAN_VERSION); go install
	sudo cp -f $(shell go env GOPATH)/bin/clipman /usr/local/bin/

swayimg-build:
	make meson-ninja-build -e APP_FOLDER=swayimg -e APP_VERSION=$(SWAYIMG_VERSION)

nwg-panel-install:
	cd nwg-panel; git checkout $(NWG_PANEL_VERSION); $(UPDATE_STATEMENT) sudo $(PIPX_ENV) pipx install . --force
	cat nwg-panel/requirements.txt | sudo $(PIPX_ENV) xargs pipx inject nwg-panel
	sudo $(PIPX_ENV) pipx inject nwg-panel requests

xdg-desktop-portal-wlr-build:
	cd xdg-desktop-portal-wlr; git fetch; git checkout $(XDG_DESKTOP_PORTAL_WLR_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)
	sudo ln -sf /usr/local/libexec/xdg-desktop-portal-wlr /usr/libexec/
	sudo mkdir -p /usr/share/xdg-desktop-portal/portals/
	sudo ln -sf /usr/local/share/xdg-desktop-portal/portals/wlr.portal /usr/share/xdg-desktop-portal/portals/

## Wayfire
wayfire-all-build: wf-config-build wayfire-build wf-shell-build wcm-build

wf-config-build:
	make meson-ninja-build -e APP_FOLDER=wf-config -e APP_VERSION=$(WF_CONFIG_VERSION)

wayfire-build:
	make meson-ninja-build -e APP_FOLDER=wayfire -e APP_VERSION=$(WAYFIRE_VERSION)

wf-shell-build:
	make meson-ninja-build -e APP_FOLDER=wf-shell -e APP_VERSION=$(WF_SHELL_VERSION)

wcm-build:
	make meson-ninja-build -e APP_FOLDER=wcm -e APP_VERSION=$(WCM_VERSION)

## Debugging
printenv:
	env
