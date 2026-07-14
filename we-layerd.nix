{
  lib,
  rustPlatform,
  fetchFromGitHub,
  cmake,
  pkg-config,
  wrapGAppsHook3,
  wayland,
  wayland-protocols,
  wayland-scanner,
  libxkbcommon,
  gtk3,
  vulkan-loader,
  vulkan-headers,
  mesa,
  libGL,
  gst_all_1,
  lz4,
  pango,
  fontconfig,
  freetype,
  libva,
  libdrm,
  glib,
  libx11,
  git,
  cef-binary,
  dxc,
  zlib,
  alsa-lib,
  pulseaudio,
  pipewire,
  openssl,
  xdotool,
  libappindicator-gtk3,
  version ? "unstable",
}:

let
  src = fetchFromGitHub {
    owner = "Aromatic05";
    repo = "we-layerd";
    rev = "7eba79da2d68d1dc9077dd463a1eb65f4aa23994";
    hash = "sha256-pxTi34sgDr+7GgTrXVOALe9s//i3Wvrmu4XKf6Cui5I=";
    fetchSubmodules = true;
  };
in
rustPlatform.buildRustPackage {
  pname = "we-layerd";
  inherit version src;

  cargoLock.lockFile = "${src}/Cargo.lock";

  cargoBuildFlags = ["--workspace"];

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
    git
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
    gtk3
    vulkan-loader
    vulkan-headers
    mesa
    libGL
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-ugly
    lz4
    pango
    fontconfig
    freetype
    libva
    libdrm
    glib
    libx11
    cef-binary
    dxc
    zlib
    alsa-lib
    pulseaudio
    pipewire
    openssl
    xdotool
    libappindicator-gtk3
  ];

  postPatch = ''
    sed -i '/fn ensure_recursive_submodules/,/^}/c\fn ensure_recursive_submodules(_upstream_root: \&Path) {}\n' build.rs
    sed -i 's/\.arg("-DBUILD_WEWEB=ON")/.arg("-DBUILD_WEWEB=ON").arg("-DBUILD_WEVIDEO=OFF")/' build.rs
    sed -i 's/pkg_check_modules(GSTREAMER REQUIRED/pkg_check_modules(GSTREAMER QUIET/' third_party/wallpaper-engine-renderer/src/render/vulkan/CMakeLists.txt
    sed -i '/target_include_directories(we-cef-helper/a\        ''${_CEF_ROOT}' third_party/wallpaper-engine-renderer/src/backend/web/CMakeLists.txt
  '';

  preConfigure = ''
    export CMAKE_MODULE_PATH="${cef-binary}/cmake:$CMAKE_MODULE_PATH"
    export CEF_ROOT="${cef-binary}"
    export HANABI_DXC_ROOT="${dxc}"
    export NIX_CFLAGS_COMPILE="''${NIX_CFLAGS_COMPILE:-} -I${libdrm.dev}/include/libdrm"
  '';

  postInstall = ''
    mkdir -p $out/lib
    cp target/we-renderer-upstream/install/lib/libwallpaper-engine-renderer.so $out/lib/
    cp target/we-renderer-upstream/install/lib/we-cef-helper $out/lib/ 2>/dev/null || true
    chmod 755 $out/lib/libwallpaper-engine-renderer.so

    # Install we-gui binary
    cp target/release/we-gui $out/bin/we-gui 2>/dev/null || true
    chmod 755 $out/bin/we-gui 2>/dev/null || true

    # Install .desktop file
    mkdir -p $out/share/applications
    cat > $out/share/applications/we-gui.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=we-gui
Comment=Wallpaper Engine helper GUI for Linux
Exec=we-gui
Icon=we-gui
Terminal=false
Categories=Utility;Graphics;
StartupNotify=true
EOF
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        zlib
        libdrm
        alsa-lib
        pulseaudio
        pipewire
        libappindicator-gtk3
        wayland
        libxkbcommon
        gtk3
        vulkan-loader
        mesa
        libGL
        glib
        libx11
        pango
        fontconfig
        freetype
        libva
      ]}
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${lib.makeSearchPath "lib/gstreamer-1.0" [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-ugly
        gst_all_1.gst-libav
      ]}
    )
  '';

  meta = with lib; {
    description = "A native Wallpaper Engine runtime for Linux Wayland";
    homepage = "https://github.com/Aromatic05/we-layerd";
    license = licenses.gpl3Plus;
    mainProgram = "we-layerd";
    longDescription = ''
      Includes:
      - we-layerd: Wallpaper Engine Wayland runtime
      - we-gui: GUI companion for workshop browsing
    '';
  };
}
