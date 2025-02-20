# `build.nvim` 🚀

A **lightweight** Neovim plugin for running shell commands (`build` and `run`) inside a temporary buffer. Perfect for **quick builds and testing** without leaving Neovim!

![Running :Build](./github/build.png)

---

## ✨ Features

✅ **Single `:Build` command** with subcommands (`build`, `run`, `setbuild`, `setrun`)
✅ Open a **bottom-right split** to execute shell commands
✅ Display **real-time stdout and stderr** output
✅ **Readonly buffer** with an exit code summary
✅ **Dynamically update build and run commands** without restarting Neovim
✅ Simple and **lightweight**, no dependencies!

---

## 📦 Installation

### **Lazy.nvim**

Add the following to your Lazy.nvim plugin list:

```lua
{
    "NewDawn0/build.nvim",
    config = function()
        require("build-nvim").setup({
            build = "make",  -- Replace with your build command
            run = "./my_program",  -- Replace with your run command
        })
    end
}
```

Run `:Lazy sync` to install the plugin.

---

### **Nix Flake Installation**

If using **Nix flakes**, you must add `build.nvim` to your `inputs` and **apply its overlay**, or else the package won't be available.

#### **Step 1: Add to Flake Inputs**

```nix
{
  inputs.build-nvim.url = "github:NewDawn0/build.nvim";
}
```

#### **Step 2: Apply Overlay**

Inside your `outputs` function:

```nix
{
  outputs = { self, nixpkgs, build-nvim, ... }:
  let
    pkgs = import nixpkgs {
      system = "x86_64-linux";  # Change to your system architecture if needed
      overlays = [ build-nvim.overlays.default ];
    };
  in {
    environment.systemPackages = with pkgs; [
      vimPlugins.build-nvim
    ];
  };
}
```

#### **Home-Manager Setup**

```nix
{
  programs.neovim.plugins = with pkgs.vimPlugins; [
    build-nvim
  ];
}
```

---

## 🚀 Usage

### **Available Commands**

| Command                 | Description                              |
| ----------------------- | ---------------------------------------- |
| `:Build build`          | Runs the configured **build** command    |
| `:Build run`            | Runs the configured **run** command      |
| `:Build setbuild <cmd>` | Sets a new **build** command dynamically |
| `:Build setrun <cmd>`   | Sets a new **run** command dynamically   |

### **Example Usage**

#### **Running Commands**

```vim
:Build build
:Build run
```

#### **Changing Commands on the Fly**

```vim
:Build setbuild gcc main.c -o my_program
:Build setrun ./my_program
```

Now, running `:Build build` will execute `gcc main.c -o my_program`, and `:Build run` will execute `./my_program`.

---

## ⚙️ Configuration

You can still set default commands in your Neovim config:

```lua
require("build-nvim").setup({
    build = "make",
    run = "./my_program",
})
```

But now you can also modify them dynamically using `:Build setbuild` and `:Build setrun` without restarting Neovim.

---

## 🔗 Links

- 📜 **GitHub**: [NewDawn0/build.nvim](https://github.com/NewDawn0/build.nvim)
