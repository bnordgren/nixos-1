source $stdenv/setup

      cp -r $src $out
      chmod 755 $out/sites/default $out
      rm -f $out/sites/default/settings.php $out/.htaccess
      sed -e "s/%DATABASE%/$dbname/g" \
          -e "s/%DB_USER%/$dbuser/g" \
          -e "s/%DB_PW%/$dbpassword/g" \
          -e "s/%DB_HOST%/$dbhost/g" \
          $settings > $out/sites/default/settings.php
      sed -e "s#%BASE_URL%#$urlPrefix#g" \
          $htaccess > $out/.htaccess
      chmod -R 755 $out/sites/default/files
      rm -rf $out/sites/default/files
      ln -s $publicDir $out/sites/default/files
      chmod 555 $out/sites/default 

