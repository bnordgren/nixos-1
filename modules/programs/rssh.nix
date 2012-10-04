# Global configuration for the rssh shell

{config, pkgs, ...}:

with pkgs.lib;

let 
  cfg  = config.programs.rssh;
  customRssh = appendToName "-custom" (pkgs.rssh.override {
     supportRsync = cfg.enableRsync ; 
     umask = cfg.umask ;
   }) ;


in
{
  ###### interface

  options = {

    programs.rssh = {

      available = mkOption { 
        default = false ;
        description = "Makes the rssh shell available.";
        type = with pkgs.lib.types; bool;
      };

      enableRsync = mkOption { 
        default = true ; 
        description = "Controls whether the rssh shell allows rsync connections." ;
        type = with pkgs.lib.types; bool;
      };

      umask = mkOption { 
        default = "022" ; 
        description = "Controls default permissions on new files.";
        type = with pkgs.lib.types; string;
      };
    };
  };


  config = mkIf cfg.available {
    environment.systemPackages = if ((cfg.umask == "022") && !cfg.enableRsync) then [pkgs.rssh] else [customRssh] ; 
  };
}
