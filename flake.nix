{
  description = "A very basic flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }: (cfg: cfg "x86_64-linux") (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      presets = [ "Web" "Linux/X11" "Windows Desktop" "Android" "macOS" ];
      godotExportTemplates = pkgs.fetchZip { };
    in
    {
      packages.${system} = rec {
        default = curvelife;
        godot_4 = pkgs.godot_4;
        curvelife = pkgs.stdenv.mkDerivation {
          name = "curvelife";
          src = ./.;
          buildPhase = ''
            mkdir -p out
            ${pkgs.godot_4}/bin/godot4 --headless --export-release "Linux/X11" out
          '';
          installPhase = ''
            mkdir -p $out
            mv out/* $out/
          '';
        };
      };
    });
}
