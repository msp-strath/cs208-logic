{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-25.05;
    opam-nix.url = "github:tweag/opam-nix";
    opam-nix.inputs.nixpkgs.follows = "nixpkgs";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, flake-utils, opam-nix, nixpkgs, opam-repository }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        tex = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            # https://tug.org/texlive/devsrc/Master/doc.html
            scheme-minimal latex-bin xetex latexmk beamer
            infwarerr kvoptions latex-tools-dev

            libertine

            mathpartir stmaryrd frankenstein multirow
            colortbl cmll euler fontspec tools extsizes
            minibox varwidth fragments psnfss csquotes
            ulem xltxtra realscripts booktabs todonotes
            pdfcomment datetime2 tracklang zref marginnote
            soulpos appendixnumberbeamer;
        };

        on = opam-nix.lib.${system};
        localPackagesQuery = builtins.mapAttrs (_: pkgs.lib.last)
          (on.listRepo (on.makeOpamRepo ./.));
        devPackagesQuery = {
          # You can add "development" packages here. They will get
          # added to the devShell automatically.
          ocaml-lsp-server = "*";
          ocamlformat = "*";
          utop = "*";
        };
        query = devPackagesQuery // {
          ## You can force versions of certain packages here, e.g:
          ## - force the ocaml compiler to be taken from opam-repository:
          ocaml-base-compiler = "5.3.0";
          ## - or force the compiler to be taken from nixpkgs and be a certain version:
          # ocaml-system = "4.14.0";
          ## - or force ocamlfind to be a certain version:
          # ocamlfind = "1.9.2";
        };
        scope = on.buildOpamProject' { repos = [opam-repository]; } ./. query;
        overlay = final: prev:
          {
            # You can add overrides here
          };
        scope' = scope.overrideScope overlay;
        # Packages from devPackagesQuery
        devPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');

        # Packages in this workspace
        opam_packages =
          pkgs.lib.getAttrs (builtins.attrNames localPackagesQuery) scope';
      in rec {
        # legacyPackages = scope';

        packages = opam_packages // {
          slides = pkgs.stdenvNoCC.mkDerivation rec {
            name = "slides";
            src = self;
            buildInputs = [ pkgs.coreutils pkgs.bash tex pkgs.gnumake ];
            phases = ["unpackPhase" "buildPhase" "installPhase"];
            buildPhase = ''
export PATH="${pkgs.lib.makeBinPath buildInputs}";
mkdir -p .cache/texmf-var;
export TEXMFHOME=.cache;
export TEXMFVAR=.cache/texmf-var;
make -C slides -j 8 all
'';
            installPhase = ''
mkdir -p $out;
for w in 1 2 3 4 5 6 7 8 9 10; do
  outfile=$(printf "week%02d-slides.pdf" $w);
  cp slides/week$w.pdf $out/$outfile;
done;
'';
          };

          site = pkgs.stdenvNoCC.mkDerivation rec {
            name = "site";
            src = self;
            buildInputs = [ packages.site_gen packages.frontend packages.slides ];
            phases = ["unpackPhase" "installPhase"];
            installPhase = ''
mkdir -p $out;
site_gen pages $out;
cp assets/*.css $out;
cp assets/sat-solver-notes.pdf $out;
cp ${packages.slides}/*.pdf $out;
cp ${packages.frontend}/share/frontend/frontend.bc.js $out;
'';
          };
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = builtins.attrValues packages;
          buildInputs = devPackages ++ [
            pkgs.rsync
          ];
        };
      });
}
