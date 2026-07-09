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
  version ? "unstable",
}:

rustPlatform.buildRustPackage {
  pname = "we-layerd";
  inherit version;

  src = fetchFromGitHub {
    owner = "Aromatic05";
    repo = "we-layerd";
    rev = "5c2a78d860893f213cc86b9a52d13e909f665e27";
    hash = "sha256-z35R+3IhFXzmNPmh3GdU9nNGUq2ok0pPT/lW8mJmtSs=";
    fetchSubmodules = true;
  };

  cargoLock.lockFile = ./Cargo.lock;

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
  '';

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        zlib
        libdrm
        alsa-lib
        pulseaudio
        pipewire
      ]}
      --prefix GST_PLUGIN_SYSTEM_PATH_1_0 : ${lib.makeSearchPath "lib/gstreamer-1.0" [
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-bad
        gst_all_1.gst-plugins-good
        gst_all_1.gst-plugins-ugly
      ]}
    )
  '';

  meta = with lib; {
    description = "A native Wallpaper Engine runtime for Linux Wayland";
    homepage = "https://github.com/Aromatic05/we-layerd";
    license = licenses.gpl3Plus;
    mainProgram = "we-layerd";
  };
}
