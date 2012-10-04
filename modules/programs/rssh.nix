# Global configuration for the rssh shell

{config, pkgs, ...}:

with pkgs.lib;

let cfg  = config.programs.rssh;

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
    };
  };


  config = mkIf cfg.available {
    environment.systemPackages = if cfg.enableRsync then [pkgs.rssh_rsync] else [pkgs.rssh] ; 
  };
}
