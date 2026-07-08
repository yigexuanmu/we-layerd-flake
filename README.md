# we-layerd-flake

[we-layerd](https://github.com/Aromatic05/we-layerd) 的 Nix Flake 打包，包含 [DirectX Shader Compiler](https://github.com/microsoft/DirectXShaderCompiler) (DXC)。

## 功能

- **we-layerd** — 基于 Rust 的 Wallpaper Engine Wayland 原生运行时，支持 layer-shell
- **DXC** — 微软官方 DirectX Shader 编译器（v1.8.2502），用于渲染 Wallpaper Engine 着色器
- 集成 GStreamer 全插件（base/bad/good/ugly）、CEF 浏览器引擎、Vulkan、PipeWire 音频

## 安装

### 作为 Flake Input（推荐）

在你的 `flake.nix` 中添加：

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    we-layerd.url = "github:yigexuanmu/we-layerd-flake";
  };

  outputs = { self, nixpkgs, we-layerd, ... } @ inputs: {
    # NixOS 系统级安装
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            we-layerd.packages.x86_64-linux.default
          ];
        }
      ];
    };

    # 或通过 Overlay 注入 nixpkgs
    nixosConfigurations.your-host = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          nixpkgs.overlays = [ we-layerd.overlays.default ];
          environment.systemPackages = [
            pkgs.we-layerd
          ];
        }
      ];
    };
  };
}
```

### Home Manager 安装

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    we-layerd.url = "github:yigexuanmu/we-layerd-flake";
  };

  outputs = { self, nixpkgs, home-manager, we-layerd, ... } @ inputs: {
    homeConfigurations.your-user = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      extraSpecialArgs = { inherit inputs; };
      modules = [
        {
          home.packages = [
            inputs.we-layerd.packages.x86_64-linux.default
          ];
        }
      ];
    };
  };
}
```

### 单独安装 DXC

```nix
# 通过 overlay
nixpkgs.overlays = [ we-layerd.overlays.default ];
environment.systemPackages = [ pkgs.dxc ];

# 或直接引用
we-layerd.packages.x86_64-linux.dxc
```

## 使用

```bash
# 运行 Wallpaper Engine 壁纸
we-layerd run --config ~/.config/we-layerd/config.toml

# 查看帮助
we-layerd --help
```

### 配置文件

创建 `~/.config/we-layerd/config.toml`：

```toml
[general]
monitor = ""

[ wallpaper ]
name = "your-wallpaper-name"
```

## 架构

```
flake.nix          # Flake 入口，输出 packages + overlay
├── dxc.nix        # DirectX Shader Compiler v1.8.2502
├── we-layerd.nix  # Wallpaper Engine Wayland 运行时
└── Cargo.lock     # we-layerd 依赖锁定
```

## 依赖

- NixOS（Wayland 会话）
- NVIDIA 或 Mesa Vulkan 驱动
- PipeWire / PulseAudio 音频服务

## 许可证

- we-layerd: GPL-3.0-or-later
- DXC: MIT
