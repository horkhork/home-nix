with (import <nixpkgs> {});
derivation {
  name = "workspace_creator";
  builder = "${bash}/bin/bash";
  args = [ ./workspace_creator.sh ];
  buildInputs = [];
}
