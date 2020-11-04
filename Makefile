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

PIP_PACKAGES=ninja meson

NINJA_CLEAN_BUILD_INSTALL=sudo ninja -C build uninstall; sudo rm build -rf; meson build; ninja -C build; sudo ninja -C build install
install-repos:
	git clone git@github.com:swaywm/sway.git || echo "Already installed"
	git clone git@github.com:swaywm/wlroots.git || echo "Already installed"
	git clone git@github.com:emersion/kanshi.git || echo "Already installed"
	git clone git@github.com:Alexays/Waybar.git || echo "Already installed"
	git clone git@github.com:mortie/swaylock-effects.git || echo "Already installed"

install-dependencies:
	sudo apt -y install $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(WAYBAR_BUILD_DEPS) $(WAYBAR_RUNTIME_DEPS) $(SWAYLOCK_DEPS)
	sudo apt -y install build-essential
	sudo pip3 install $(PIP_PACKAGES) --upgrade

clean-dependencies:
	sudo apt autoremove --purge $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(WAYBAR_DEPS) $(SWAYLOCK_DEPS)

wlroots-build:
	cd wlroots; $(NINJA_CLEAN_BUILD_INSTALL)

sway-build:
	cd sway; $(NINJA_CLEAN_BUILD_INSTALL)

kanshi-build:
	cd kanshi; $(NINJA_CLEAN_BUILD_INSTALL)

waybar-build:
	cd Waybar; $(NINJA_CLEAN_BUILD_INSTALL)

swaylock-build:
	cd swaylock-effects; $(NINJA_CLEAN_BUILD_INSTALL)
