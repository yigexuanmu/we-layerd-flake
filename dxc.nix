{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation {
  pname = "directx-shader-compiler";
  version = "1.8.2502";

  src = fetchurl {
    url = "https://github.com/microsoft/DirectXShaderCompiler/releases/download/v1.8.2502/linux_dxc_2025_02_20.x86_64.tar.gz";
    hash = "sha256-4FgNkNv2BTp4Pd2NUVMoXwYG5d6q0Xp6ZFLwOs34jHE=";
  };

  dontBuild = true;

  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out
    cp -r bin $out/
    cp -r include $out/
    cp -r lib $out/
    chmod 755 $out/bin/dxc
    chmod 755 $out/lib/libdxcompiler.so
  '';

  meta = with lib; {
    description = "DirectX Shader Compiler";
    homepage = "https://github.com/microsoft/DirectXShaderCompiler";
    license = licenses.mit;
  };
}
