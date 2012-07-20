source $stdenv/setup 

cd $TMPDIR
jar xf $geonetwork/$warfile

cat > db << END 
${databaseConfig}
END

sed -e "s#%UPLOAD%#${uploadDir}#g" \
    -e "s#%MAX_UPLOAD%#${uploadMax}#g" \
    -e "s#%DATADIR%#${dataDir}#g" \
    -e "s#%THESAURIIDIR%#${thesauriiDir}#g" \
    -e "/%DATABASE_CONFIG%/r db" \
    -e "/%DATABASE_CONFIG%/d" $configTemplate > WEB-INF/config.xml

sed -e "s#%EXTENT%#${extent}#g" \
    -e "s#%GEOSERVER_URL%#${geoserverUrl}#g" \
     $guiTemplate > WEB-INF/config-gui.xml

sed "s#%LOGFILE%#${logfile}#g" $logTemplate > WEB-INF/log4j.cfg

rm db 
mkdir -p $out
jar cf $out/geonetwork.war .

