source $stdenv/setup 

cd $TMPDIR
$jdk/bin/jar xf $geonetwork/$warfile

cp -r . $out
