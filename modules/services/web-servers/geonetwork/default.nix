{ config, pkgs,  ... }:

with pkgs.lib;

let

  cfg = config.services.geonetwork;
  tomcatCfg = config.services.tomcat;
  tomcat = pkgs.tomcat6;
  geonetwork = pkgs.geonetwork;

  geonetworkconf = pkgs.stdenv.mkDerivation { 
    name    = "geonetwork-conf" ;
    builder = ./builder.sh ;
    configTemplate = ./config-template.xml;
    guiTemplate = ./config-gui.xml ;
    logTemplate = ./log4j.cfg ; 
    buildInputs = [ pkgs.jdk ] ; 
    inherit (pkgs) geonetwork ; 
    inherit (pkgs.geonetwork) warfile ; 
    inherit (cfg) uploadMax uploadDir dataDir thesauriiDir databaseConfig extent logfile ; 
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

      uploadMax = mkOption { 
        default = 100 ; 
        description = "Maximum size of uploaded file (Mb)" ; 
      };

      baseDir = mkOption {
        default = "/var/geonetwork" ; 
        description = "Base directory in which Geonetwork stores persistent data" ;  
      } ; 

      uploadDir = mkOption { 
        default = "${cfg.baseDir}/uploads" ; 
        description = "Directory to contain files uploaded to Geonetwork" ; 
      };

      dataDir = mkOption { 
        default = "${cfg.baseDir}/data" ; 
        description = "Directory to contain metadata uploaded to Geonetwork" ; 
      };

      thesauriiDir = mkOption { 
        default = "${cfg.baseDir}/thesaurii" ; 
        description = "Directory to contain thesaurii maintained by Geonetwork" ; 
      };

      extent = mkOption {
        default = "-180,-90,180,90" ; 
        description = "Initial extent for the search map and the map viewer.";  
      } ; 

      logfile = mkOption { 
        default = "${tomcatCfg.baseDir}/logs/geonetwork.log" ; 
        description = "Log file for the geonetwork web application." ; 
      } ; 

      databaseConfig = mkOption { 
        description = "Geonetwork XML configuration for database connection" ; 
        default = ''		<resource enabled="true">
			<name>main-db</name>
			<provider>jeeves.resources.dbms.DbmsPool</provider>
			<config>
				<user>BayACrsQ</user>
				<password>Qf7Po9T0</password>
				<driver>com.mckoi.JDBCDriver</driver>
				<url>jdbc:mckoi://localhost:9157/</url>
				<poolSize>10</poolSize>
			</config>


		<activator class="org.fao.geonet.activators.McKoiActivator"><configFile>WEB-INF/db/db.conf</configFile></activator>
                </resource>
'';

        example = ''
Choose only one of the following resources and ensure that "enabled" = true
		<resource enabled="true">
			<name>main-db</name>
			<provider>jeeves.resources.dbms.DbmsPool</provider>
			<config>
				<user>BayACrsQ</user>
				<password>Qf7Po9T0</password>
				<driver>com.mckoi.JDBCDriver</driver>
				<url>jdbc:mckoi://localhost:9157/</url>
				<poolSize>10</poolSize>
			</config>


		<activator class="org.fao.geonet.activators.McKoiActivator"><configFile>WEB-INF/db/db.conf</configFile></activator>
                </resource>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- mysql -->
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<resource enabled="false">
			<name>main-db</name>
			<provider>jeeves.resources.dbms.DbmsPool</provider>
			<config>
				<user>admin</user>
				<password>admin</password>
				<driver>com.mysql.jdbc.Driver</driver>
				<url>jdbc:mysql://$WEBSERVER_HOST/geonetwork</url>
				<poolSize>10</poolSize>
				<reconnectTime>3600</reconnectTime>
			</config>
		</resource>

		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- oracle -->
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<resource enabled="false">
			<name>main-db</name>
			<provider>jeeves.resources.dbms.DbmsPool</provider>
			<config>
				<user>admin</user>
				<password>admin</password>
				<driver>oracle.jdbc.driver.OracleDriver</driver>
				<url>jdbc:oracle:thin:@IP:1521:fs</url>
				<poolSize>10</poolSize>
			</config>
		</resource>
	    
	    
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- postgresql -->
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		
		<resource enabled="false">
			<name>main-db</name>
			<provider>jeeves.resources.dbms.DbmsPool</provider>
			<config>
				<user>www-data</user>
				<password>www-data</password>
				<driver>org.postgresql.Driver</driver>
				<!--					
					jdbc:postgresql:database
					jdbc:postgresql://host/database
					jdbc:postgresql://host:port/database
				-->
                <url>jdbc:postgresql:geonetwork</url>
				<poolSize>10</poolSize>
			</config>
		</resource>
	    
	    
	    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
		<!-- sqlserver 2008 -->
		<!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

		<resource enabled="false">
			<name>main-db</name>
			<provider>jeeves.resources.dbms.DbmsPool</provider>
			<config>
				<user>www-data</user>
				<password>www-data</password>
				  <driver>com.microsoft.sqlserver.jdbc.SQLServerDriver</driver>
                  <url>jdbc:sqlserver://SERVER;database=geonetwork;integratedSecurity=false;</url>
				<poolSize>10</poolSize>
			</config>
		</resource>
'' ; 
 
      } ; 

    };

  };


  ###### implementation

  config = mkIf config.services.geonetwork.enable {

    services.tomcat = {
       enable = config.services.geonetwork.enable ; 
       webapps = [ "${geonetworkconf}/geonetwork.war" ] ; 
    } ;

    jobs.geonetwork = { 
       description = "Geonetwork server (deployed in Tomcat)" ; 
       startOn = "started tomcat" ; 
       stopOn  = "stopping tomcat" ; 

       preStart = ''
            # create the various directories if necessary
            mkdir -p ${cfg.uploadDir}
            mkdir -p ${cfg.dataDir}
            mkdir -p ${cfg.thesauriiDir}
            chown -R ${tomcatCfg.user}.${tomcatCfg.group} ${cfg.uploadDir} ${cfg.dataDir} ${cfg.thesauriiDir}
       '' ;
    } ; 
  };

}
