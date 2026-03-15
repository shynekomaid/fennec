{
  description = "Fennec — minimal Firefox userChrome.css setup";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }: {
    homeManagerModules.default = import ./nix/module.nix self;
    homeManagerModules.fennec = import ./nix/module.nix self;
  };
}
