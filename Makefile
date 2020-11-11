# Define here which branches or tags you want to build for each project
SWAY_VERSION ?= master
WLROOTS_VERSION ?= master
KANSHI_VERSION ?= master
WAYBAR_VERSION ?= master
SWAYLOCK_VERSION ?= master
MAKO_VERSION ?= master
WF_RECORDER_VERSION ?= master
CLIPMAN_VERSION ?= master
PIPEWIRE_VERSION ?= master

ifdef UPDATE
	UPDATE_STATEMENT = git pull;
endif

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
	cmake \
	libpng-dev \
	libavutil-dev \
	libavcodec-dev \
	libavformat-dev \
	libxcb-composite0-dev \
	libxcb-icccm4-dev \
	libxcb-image0-dev \
	libxcb-render0-dev \
	libxcb-xfixes0-dev \
	libxkbcommon-dev \
	libxcb-xinput-dev \
	libx11-xcb-dev
endef

define SWAY_DEPS
	libjson-c-dev \
	libpango1.0-dev \
	libcairo2-dev \
	libgdk-pixbuf2.0-dev \
	scdoc
endef

define GTK_LAYER_DEPS
	libgtk-layer-shell-dev \
	libgtk-layer-shell0
endef

define WAYBAR_BUILD_DEPS
	libgtkmm-3.0-dev \
	libspdlog-dev \
	libjsoncpp-dev \
	libfmt-dev \
	libpulse-dev \
	libnl-3-dev \
	libnl-genl-3-dev \
	libappindicator3-dev \
	libdbusmenu-gtk3-dev
endef

define WAYBAR_RUNTIME_DEPS
	libgtkmm-3.0-1v5 \
	libspdlog1 \
	libjsoncpp1 \
	libnl-3-200 \
	libnl-genl-3-200 \
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

define CLIPMAN_DEPS
	golang-go
endef

define PIPEWIRE_DEPS
	libgstreamer1.0-dev \
	libgstreamer-plugins-base1.0-dev \
	libasound2-dev \
	libbluetooth-dev \
	libsbc-dev \
	libjack-jackd2-dev \
	libsdl2-dev \
	libsndfile1-dev
endef

PIP_PACKAGES=ninja meson

NINJA_CLEAN_BUILD_INSTALL=$(UPDATE_STATEMENT) sudo ninja -C build uninstall; sudo rm build -rf; meson build; ninja -C build; sudo ninja -C build install

yolo: install-repos install-dependencies wlroots-build sway-build kanshi-build waybar-build swaylock-build mako-build wf-recorder-build clipman-build wofi-build

install-repos:
	@git clone https://github.com/swaywm/sway.git || echo "Already installed"
	@git clone https://github.com/swaywm/wlroots.git || echo "Already installed"
	@git clone https://github.com/emersion/kanshi.git || echo "Already installed"
	@git clone https://github.com/Alexays/Waybar.git || echo "Already installed"
	@git clone https://github.com/mortie/swaylock-effects.git || echo "Already installed"
	@git clone https://github.com/emersion/mako.git || echo "Already installed"
	@git clone https://github.com/ammen99/wf-recorder.git || echo "Already installed"
	@git clone https://github.com/yory8/clipman.git || echo "Already installed"
	@git clone https://github.com/PipeWire/pipewire.git || echo "Already installed"
	@hg clone https://hg.sr.ht/~scoopta/wofi || echo "Already installed"

install-dependencies:
	sudo apt -y install --no-install-recommends \
		$(WLROOTS_DEPS) \
		$(SWAY_DEPS) \
		$(GTK_LAYER_DEPS) \
		$(WAYBAR_BUILD_DEPS) \
		$(WAYBAR_RUNTIME_DEPS) \
		$(SWAYLOCK_DEPS) \
		$(WF_RECORDER_DEPS) \
		$(CLIPMAN_DEPS) \
		$(PIPEWIRE_DEPS)

	sudo apt -y install build-essential
	sudo pip3 install $(PIP_PACKAGES) --upgrade

clean-dependencies:
	sudo apt autoremove --purge $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(WAYBAR_DEPS) $(SWAYLOCK_DEPS) $(WF_RECORDER_DEPS)

core: wlroots-build sway-build

wlroots-build:
	cd wlroots; git fetch; git checkout $(WLROOTS_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

sway-build:
	cd sway; git fetch; git checkout $(SWAY_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

kanshi-build:
	cd kanshi; git fetch; git checkout $(KANSHI_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

waybar-build:
	cd Waybar; git fetch; git checkout $(WAYBAR_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

swaylock-build:
	cd swaylock-effects; git fetch; git checkout $(SWAYLOCK_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

mako-build:
	cd mako; git fetch;  git checkout $(MAKO_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

wf-recorder-build:
	cd wf-recorder; git fetch; git checkout $(WF_RECORDER_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

clipman-build:
	cd clipman; git fetch; git checkout $(CLIPMAN_VERSION); go install; sudo cp -f ~/go/bin/clipman /usr/local/bin/

wofi-build:
	cd wofi; hg pull; hg update; $(NINJA_CLEAN_BUILD_INSTALL)
	ln -sf $(shell pwd)/wofi/build/wofi ~/bin/

# Experimental stuff
pipewire-build:
	sudo apt install -y --no-install-recommends $(PIPEWIRE_DEPS)
	cd pipewire; git fetch; git checkout $(PIPEWIRE_VERSION); $(NINJA_CLEAN_BUILD_INSTALL)

pipewire-remove:
	sudo apt autoremove --purge -y $(PIPEWIRE_DEPS)
	cd pipewire; sudo ninja -C build uninstall
