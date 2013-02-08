# Global configuration for gridftp lite (authentication via ssh) 

{config, pkgs, ...}:

with pkgs.lib;

let 
  cfg  = config.programs.gridftp_lite;
  sshftp = builtins.storePath (builtins.toFile "sshftp" ''
          #!/bin/sh
          
          #
          # Copyright 1999-2006 University of Chicago
          #
          # Licensed under the Apache License, Version 2.0 (the "License");
          # you may not use this file except in compliance with the License.
          # You may obtain a copy of the License at
          #
          # http://www.apache.org/licenses/LICENSE-2.0
          #
          # Unless required by applicable law or agreed to in writing, software
          # distributed under the License is distributed on an "AS IS" BASIS,
          # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
          # See the License for the specific language governing permissions and
          # limitations under the License.
          #
          
          if [ -z "\$GLOBUS_LOCATION" ]; then
              GLOBUS_LOCATION=${pkgs.gridftp}
              export GLOBUS_LOCATION
          fi
          
          if [ -f \$GLOBUS_LOCATION/etc/globus-user-env.sh ]; then
              . \$GLOBUS_LOCATION/etc/globus-user-env.sh
          fi
          
          #export GLOBUS_TCP_PORT_RANGE=50000,50100
          
          exec \$GLOBUS_LOCATION/sbin/globus-gridftp-server -ssh
          # -data-interface <interface to force data connections>'');

in
{
  ###### interface

  options = {

    programs.gridftp_lite = {

      available = mkOption { 
        default = false ;
        description = "Makes gridftp available via ssh";
        type = with pkgs.lib.types; bool;
      };
    };
  };


  config = mkIf cfg.available {
    environment.systemPackages = [pkgs.gridftp];
    environment.etc = [ 
      { source = sshftp;
        target = "grid-security/sshftp";
      }
    ];
  };
}
