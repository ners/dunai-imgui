{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-filter.url = "github:numtide/nix-filter";
    dunai = {
      url = "github:ivanperez-keera/dunai";
      flake = false;
    };
    rhine = {
      url = "github:turion/rhine";
      flake = false;
    };
    imgui = {
      url = "github:ocornut/imgui/v1.89.9";
      flake = false;
    };
    imgui-hs = {
      url = "github:haskell-game/dear-imgui.hs";
      flake = false;
    };
  };

  outputs = inputs:
    let
      inherit (inputs.nixpkgs) lib;
      foreach = xs: f: with lib; foldr recursiveUpdate { } (
        if isList xs then map f xs
        else if isAttrs xs then mapAttrsToList f xs
        else error "foreach: expected list or attrset but got ${builtins.typeOf xs}"
      );
      hsSrc = pname: inputs.nix-filter {
        root = ./${pname};
        include = [
          "lib"
          "src"
          "test"
          "${pname}.cabal"
        ];
      };
      mkLib = hp: pname: { "${pname}" = hp.callCabal2nix pname (hsSrc pname) { }; };
      pnames = [ "dunai-imgui" "bearriver-imgui" "rhine-imgui" ];
    in
    foreach inputs.nixpkgs.legacyPackages (system: pkgs:
      let
        defaultGhc = builtins.replaceStrings ["-" "."] ["" ""] pkgs.haskellPackages.ghc.name;
      in
      lib.recursiveUpdate
        {
          formatter.${system} = pkgs.nixpkgs-fmt;
          packages.${system}.default = inputs.self.packages.${system}.${defaultGhc}.dunai-imgui;
          devShells.${system}.default = inputs.self.devShells.${system}.${defaultGhc};
        }
        (foreach (lib.filterAttrs (name: _: builtins.match "ghc[0-9]+" name != null) pkgs.haskell.packages)
          (ghcName: haskellPackages:
            let
              hp = haskellPackages.override {
                overrides = self: super:
                  with pkgs.haskell.lib.compose;
                  builtins.trace "GHC ${super.ghc.version}"
                  {
                    dunai = self.callCabal2nix "dunai" "${inputs.dunai}/dunai" { };
                    bearriver = self.callCabal2nix "bearriver" "${inputs.dunai}/dunai-frp-bearriver" { };
                    rhine = doJailbreak (self.callCabal2nix "rhine" "${inputs.rhine}/rhine" { });
                    dear-imgui = lib.pipe inputs.imgui-hs [
                      (src: self.callCabal2nix "dear-imgui" src {})
                      (drv: drv.overrideAttrs (attrs: {
                        postPatch = ''
                          ${attrs.postPatch or ""}
                          rmdir ./imgui
                          ln -s ${inputs.imgui} ./imgui
                        '';
                        buildInputs = with pkgs; [
                          gcc
                          glew
                          SDL2
                        ]
                        ++ attrs.nativeBuildInputs or [];
                      }))
                    ];
                  }
                // foreach pnames (mkLib self)
                // lib.optionalAttrs (lib.versionAtLeast super.ghc.version "9.6") {
                  fourmolu = super.fourmolu_0_14_0_0;
                };
              };
            in
            {
              packages.${system}.${ghcName} = foreach pnames (pname: {
                "${pname}" = hp.${pname};
              });
              devShells.${system}.${ghcName} = hp.shellFor {
                packages = ps: builtins.map (pname: ps.${pname}) pnames;
                nativeBuildInputs = with hp; [
                  cabal-install
                  fourmolu
                  haskell-language-server
                ];
              };
            }
          )
        ));
}
