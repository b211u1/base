# Auto-import all language modules in this directory
# Following vimjoyer's pattern: https://github.com/vimjoyer/modularize-video
{ pkgs, lib ? pkgs.lib }:

let
  # Get all .nix files except default.nix
  files = builtins.readDir ./.;
  nixFiles = lib.filterAttrs 
    (name: type: type == "regular" && name != "default.nix" && lib.hasSuffix ".nix" name) 
    files;
  
  # Import each file and create an attrset
  modules = lib.mapAttrs' 
    (filename: _: {
      name = lib.removeSuffix ".nix" filename;
      value = import (./. + "/${filename}") { inherit pkgs; };
    }) 
    nixFiles;
in
modules
