source $stdenv/setup 

cd $TMPDIR
$jdk/bin/jar xf $geoserver/$warfile


sed -e "s#%DATADIR%#${dataDir}#g"  $configTemplate > WEB-INF/web.xml

# Add the optional extension to geoserver
if [ $pyramids ] ; then
  cp $geoserverPyramid/$jarfile WEB-INF/lib
fi 

mkdir -p $out
$jdk/bin/jar cf $out/geoserver.war .
