{
  description = "A minimal plugin to run build by keybind";

  inputs.utils.url = "github:NewDawn0/nixUtils";

  outputs = { self, utils }: {
    overlays.default = final: prev: {
      vimPlugins = prev.vimPlugins // {
        build-nvim = self.packages.${prev.system}.default;
      };
    };
    packages = utils.lib.eachSystem { } (pkgs: {
      default = pkgs.vimUtils.buildVimPlugin {
        name = "build-nvim";
        src = ./.;
        meta = {
          description = "A minimal plugin to run build by keybind";
          homepage = "https://github.com/NewDawn0/build.nvim";
          license = pkgs.lib.licenses.mit;
          maintainers = with pkgs.lib.maintainers; [ NewDawn0 ];
        };
      };
    });
  };
}
