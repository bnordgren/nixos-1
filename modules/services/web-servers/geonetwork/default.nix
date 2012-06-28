{ config, pkgs,  ... }:

with pkgs.lib;

let

  cfg = config.services.geonetwork;
  tomcat = pkgs.tomcat6;
  geonetwork = pkgs.geonetwork;

  geonetworkconf = pkgs.stdenv.mkDerivation { 
    name    = "geonetwork-conf" ;
    builder = ./builder.sh ;
    inherit (pkgs) geonetwork jdk ; 
    inherit (pkgs.geonetwork) warfile ; 
  } ; 
in

{

  imports = [ ../tomcat.nix ] ;

  ###### interface

  options = {

    services.geonetwork = {

      enable = mkOption {
        default = false;
        description = "Whether to enable Geonetwork Opensource";
      };

    };

  };


  ###### implementation

  config = mkIf config.services.geonetwork.enable {

    services.tomcat = {
       enable = config.services.geonetwork.enable ; 
       webapps = [ geonetworkconf ] ; 
    } ;

  };

}
