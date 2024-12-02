{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        elixir
        elixir-ls
      ];
    };

    packages.${system} = {
      hello = pkgs.hello;
      default = self.packages.${system}.hello;
    };
  };
}
