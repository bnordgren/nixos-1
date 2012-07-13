{ config, pkgs,  ... }:

with pkgs.lib;

let

  cfg = config.services.geoserver;
  tomcatCfg = config.services.tomcat;
  tomcat = pkgs.tomcat6;

  geoserverconf = pkgs.stdenv.mkDerivation { 
    name    = "geoserver-conf" ;
    builder = ./builder.sh ;
    configTemplate = ./web.xml;
    inherit (pkgs) geoserver geoserverPyramid jdk ; 
    inherit (pkgs.geoserver) warfile ; 
    inherit (pkgs.geoserverPyramid) jarfile ; 
    inherit (cfg) dataDir pyramids ; 
  } ; 
in

{

  imports = [ ../tomcat.nix ] ;

  ###### interface

  options = {

    services.geoserver = {

      enable = mkOption {
        default = false;
        description = "Whether to enable geoserver.";
      };

      pyramids = mkOption {  
        default = false ; 
        description = "Whether to include the Image Pyramid extension" ; 
      } ; 

      dataDir = mkOption { 
        default = "/var/geoserver" ; 
        description = "Geoserver's data directory" ; 
      };

    };

  };


  ###### implementation

  config = mkIf config.services.geoserver.enable {

    services.tomcat = {
       enable = config.services.geoserver.enable ; 
       webapps = [ "${geoserverconf}/geoserver.war" ] ; 
    } ;

    jobs.geoserver = { 
       description = "Geoserver (deployed in Tomcat)" ; 
       startOn = "started tomcat" ; 
       stopOn  = "stopping tomcat" ; 

       preStart = ''
            # create the upload directory
            mkdir -p ${cfg.dataDir}
            chown -R ${tomcatCfg.user}.${tomcatCfg.group} ${cfg.dataDir}
       '' ;
    } ; 
  };

}
