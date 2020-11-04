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

PIP_PACKAGES=ninja meson

NINJA_CLEAN_BUILD_INSTALL=sudo ninja -C build uninstall; rm build -rf; meson build; sudo ninja -C build install
install-repos:
	git clone git@github.com:swaywm/sway.git
	git clone git@github.com:swaywm/wlroots.git
	git clone git@github.com:emersion/kanshi.git
	git clone git@github.com:Alexays/Waybar.git

install-dependencies:
	# wlroots
	sudo apt -y install $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(WAYBAR_BUILD_DEPS) $(WAYBAR_RUNTIME_DEPS)
	sudo apt -y install essential
	sudo pip3 install $(PIP_PACKAGES) --upgrade

clean-dependencies:
	sudo apt autoremove --purge $(WLROOTS_DEPS) $(SWAY_DEPS) $(GTK_LAYER_DEPS) $(WAYBAR_DEPS)

wlroots-build:
	cd wlroots; $(NINJA_CLEAN_BUILD_INSTALL)

sway-build:
	cd sway; $(NINJA_CLEAN_BUILD_INSTALL)

kanshi-build:
	cd kanshi; $(NINJA_CLEAN_BUILD_INSTALL)

waybar-build:
	cd Waybar; $(NINJA_CLEAN_BUILD_INSTALL)
