source $stdenv/setup 

cd $TMPDIR
jar xf $geonetwork/$warfile

cat > db << END 
${databaseConfig}
END

sed -e "s#%UPLOAD%#${uploadDir}#g" \
    -e "/%DATABASE_CONFIG%/r db" \
    -e "/%DATABASE_CONFIG%/d" $configTemplate > WEB-INF/config.xml

sed "s#%EXTENT%#${extent}#g" $guiTemplate > WEB-INF/config-gui.xml

sed "s#%LOGFILE%#${logfile}#g" $logTemplate > WEB-INF/log4j.cfg

mkdir -p $out
jar cf $out/geonetwork.war .

