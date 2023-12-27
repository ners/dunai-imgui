{
  nixConfig = {
    extra-experimental-features = "nix-command flakes";
    extra-substituters = "https://cache.ners.ch/haskell";
    extra-trusted-public-keys = "haskell:WskuxROW5pPy83rt3ZXnff09gvnu80yovdeKDw5Gi3o=";
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-filter.url = "github:numtide/nix-filter";
    dunai = {
      url = "github:ivanperez-keera/dunai";
      flake = false;
    };
    rhine = {
      url = "github:ners/rhine/dunai-0.12";
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
          (inputs.nix-filter.lib.matchExt "cabal")
          (inputs.nix-filter.lib.matchExt "md")
        ];
      };
      pnames = [ "dunai-imgui" "bearriver-imgui" "rhine-imgui" ];
      overlay = final: prev: {
        haskell = prev.haskell // {
          packageOverrides = lib.composeExtensions prev.haskell.packageOverrides (hfinal: hprev:
            with prev.haskell.lib.compose;
            {
              dunai = hfinal.callCabal2nix "dunai" "${inputs.dunai}/dunai" { };
              bearriver = hfinal.callCabal2nix "bearriver" "${inputs.dunai}/dunai-frp-bearriver" { };
              rhine = doJailbreak (hfinal.callCabal2nix "rhine" "${inputs.rhine}/rhine" { });
              dear-imgui = (hfinal.callCabal2nix "dear-imgui" inputs.imgui-hs { }).overrideAttrs (attrs: {
                postPatch = ''
                  ${attrs.postPatch or ""}
                  rmdir ./imgui
                  ln -s ${inputs.imgui} ./imgui
                '';
                buildInputs = with prev; [
                  gcc
                  glew
                  SDL2
                ]
                ++ attrs.nativeBuildInputs or [ ];
              });
            }
            // foreach pnames (pname: {
              "${pname}" = lib.pipe pname [
                (pname: hfinal.callCabal2nix pname (hsSrc pname) { })
                dontCheck
                dontCoverage
                dontHaddock
              ];
            })
          );
        };
      };
    in
    foreach inputs.nixpkgs.legacyPackages (system: pkgs':
      let pkgs = pkgs'.extend overlay; in
      {
        formatter.${system} = pkgs.nixpkgs-fmt;
        legacyPackages.${system} = pkgs;
        packages.${system}.default = pkgs.buildEnv {
          name = "dunai-imgui";
          paths = builtins.map (pname: pkgs.haskellPackages.${pname}) pnames;
        };
        devShells.${system} =
          foreach (pkgs.haskell.packages // { default = pkgs.haskellPackages; }) (ghcName: hp: {
            ${ghcName} = hp.shellFor {
              packages = ps: builtins.map (pname: ps.${pname}) pnames;
              nativeBuildInputs = with hp; [
                cabal-install
                fourmolu
                haskell-language-server
              ];
            };
          });
      }
    );
}
