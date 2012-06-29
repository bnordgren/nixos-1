source $stdenv/setup 

cd $TMPDIR
$jdk/bin/jar xf $geonetwork/$warfile

cat > db << END 
${databaseConfig}
END

sed -e "s#%UPLOAD%#${uploadDir}#g" \
    -e "/%DATABASE_CONFIG%/r db" \
    -e "/%DATABASE_CONFIG%/d" $configTemplate > WEB-INF/config.xml

mkdir -p $out
$jdk/bin/jar cf $out/geonetwork.war .

