source $stdenv/setup


mkdir -p $out/$bindir

# set up the web application
cp -r $src $out/$webapp
chmod 755 $out/$webapp/sites/default $out/$webapp
rm -f $out/$webapp/sites/default/settings.php $out/$webapp/.htaccess
sed -e "s/%DATABASE%/$dbname/g" \
          -e "s/%DB_USER%/$dbuser/g" \
          -e "s/%DB_PW%/$dbpassword/g" \
          -e "s/%DB_HOST%/$dbhost/g" \
          $settings > $out/$webapp/sites/default/settings.php
sed -e "s#%BASE_URL%#$urlPrefix#g" \
          $htaccess > $out/$webapp/.htaccess
chmod -R 755 $out/$webapp/sites/default/files
rm -rf $out/$webapp/sites/default/files
ln -s $publicDir $out/$webapp/sites/default/files
chmod 555 $out/$webapp/sites/default 

#create the backup and restore scripts
sed -e "s/%DATABASE%/$dbname/g" \
          -e "s/%DB_USER%/$dbuser/g" \
          -e "s/%DB_PW%/$dbpassword/g" \
          -e "s/%DB_HOST%/$dbhost/g" \
          -e "s#%MYSQL%#$mysql#g" \
          -e "s#%GZIP%#$gzip#g" \
          $backup > $out/$bindir/backup-$dbname

sed -e "s/%DATABASE%/$dbname/g" \
          -e "s/%DB_USER%/$dbuser/g" \
          -e "s/%DB_PW%/$dbpassword/g" \
          -e "s/%DB_HOST%/$dbhost/g" \
          -e "s#%MYSQL%#$mysql#g" \
          -e "s#%GZIP%#$gzip#g" \
          $restore > $out/$bindir/restore-$dbname
