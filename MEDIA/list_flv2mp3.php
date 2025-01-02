<?php
   $path = ($_REQUEST['path']!="")?$_REQUEST['path']:$argv[1];
   if ($path!="") {
      if ($handle = opendir($path)) {
         $arrFileNames = array();
         while (false !== ($file = readdir($handle))) {
            if (substr($file,-3)=="flv") {
               array_push($arrFileNames,str_replace(".flv","",$file));
            }
         }
         closedir($handle);
      }

      foreach($arrFileNames as $file_name) {
         $cmd = "avconv -i \"{$path}/{$file_name}.flv\" -ab 192k -ar 44100 {$path}/".str_replace(" ","_",$file_name).".mp3";
         print `$cmd`;
      }
   } else {
      print "Path no pasado como argumento";
   }
?>
