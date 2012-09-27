{ config, pkgs, serverInfo, php, ... }:

with pkgs.lib;

let 
  rxdrupalConfigured = pkgs.stdenv.mkDerivation rec {
    name= "rxdrupalConfigured-7.15";
    builder = ./rxdrupal.sh ;
    src = pkgs.rxdrupal;

    # variables needed by the builder.
    dbname = config.dbname ;
    dbuser = config.dbuser;
    dbpassword = config.dbpassword;
    dbhost     = config.dbhost;
    urlPrefix  = config.urlPrefix ;
    settings   = pkgs.rxdrupal.settings;
    htaccess   = pkgs.rxdrupal.htaccess;
    publicDir  = config.publicUploadDir;
  } ;

in 

{
  extraConfig = ''
        Alias ${config.urlPrefix} "${rxdrupalConfigured}"
        <Directory "${rxdrupalConfigured}">
                AllowOverride All
                Options FollowSymlinks
                Order allow,deny
                Allow from all
                php_admin_value open_basedir "${rxdrupalConfigured}:${config.publicUploadDir}:${config.privateUploadDir}:${config.tmpUploadDir}"
        </Directory>
        <Directory "${config.publicUploadDir}">
		AllowOverride None
		Order allow,deny
		Allow from all
	</Directory>
  '';



  enablePHP = true;

  options = {

    urlPrefix = mkOption {
      default = "/working";
      description = ''
        The URL prefix under which the drupal service appears.
      '';
    };

    publicUploadDir = mkOption {
      default = throw "You must specify `publicUploadDir'.";
      example = "";
      description = ''The directory that stores uploaded files to be served by the http server.
        This directory will be symlinked to sites/default/files.'';
    };
    privateUploadDir = mkOption {
      default = "/mnt/rxcadre/drupal/private";
      example = "/mnt/rxcadre/drupal";
      description = "The directory that stores private uploaded files.";
    };
    tmpUploadDir = mkOption {
      default = "/mnt/rxcadre/drupal/tmp";
      example = "/mnt/rxcadre/drupal/tmp";
      description = "The directory that stores temporary files.";
    };


    dbname = mkOption {
      default = "drupal";
      description = "Name of the database drupal connects to." ; 
      example = "drupal"; 
    };
    dbuser = mkOption {
      default = "drupaluser";
      description = "Database user Drupal uses when connecting to the database.";
      example = "drupaluser";
    };
    dbpassword = mkOption {
      default = throw "You must specify dbpassword!";
      description = "Password Drupal uses to connect to the database." ;
    };
    dbhost = mkOption {
      default = "localhost";
      description = "Host name on which the database server is running." ; 
      example = "db.example.com" ;
    };
  };

}
