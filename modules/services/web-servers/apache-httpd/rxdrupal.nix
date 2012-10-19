{ config, pkgs, serverInfo, php, ... }:

with pkgs.lib;

let 
  rxdrupalConfigured = pkgs.stdenv.mkDerivation rec {
    name= "rxdrupalConfigured-7.16";
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
    webapp     = "webapp";
    bindir     = "bin";
    mysql      = pkgs.mysql ; 
    gzip       = pkgs.gzip ;

    backup     = ./backup.sh ;
    restore    = ./restore.sh ;
  } ;

  webapp_base = "${rxdrupalConfigured}/${rxdrupalConfigured.webapp}";


in 

{

  extraConfig = ''
        Alias ${config.urlPrefix} "${webapp_base}"
        <Directory "${webapp_base}">
                AllowOverride All
                Options FollowSymlinks
                Order allow,deny
                Allow from all
                php_admin_flag engine on
                php_admin_value open_basedir "${webapp_base}:${config.publicUploadDir}:${config.privateUploadDir}:${config.tmpUploadDir}"
                php_admin_value upload_tmp_dir "${config.tmpUploadDir}"
                php_admin_value upload_max_filesize "${config.maxUploadSize}"
                php_admin_value post_max_size "${config.postMaxSize}"
                php_admin_value max_file_uploads ${config.maxFileUploads}
        </Directory>
        <Directory "${config.publicUploadDir}">
                AllowOverride Options
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
    maxUploadSize = mkOption {
      default = "2M";
      example = "256M";
      description = "This sets the upload_max_filesize php.ini variable. It is a string to accomodate the K/M suffixes.";
    };
    maxFileUploads = mkOption {
      default = "10";
      example = "20";
      description = "This sets the max_file_uploads php.ini variable. Only use integers.";
    };
    postMaxSize = mkOption {
      default = "2M";
      example = "256M";
      description = ''This sets the post_max_size php.ini variable. It is a string to accomodate the K/M suffixes.
	It should be a multiple of maxUploadSize.'';
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
