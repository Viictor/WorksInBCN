<?php

    /* Se descarga el fichero XML de la web opendata.bcn.cat */
    $file = file_get_contents('obres.json');

    /* Se convierte el XML a JSON y se guarda en una estructura array */
    $array = json_decode($file,TRUE);
    $file = NULL;

    // echo '<style>';
    // echo 'img {display:block;}';
    // echo '</style>';

    echo '<ul>';

    for ($i=0; $i < count($array); $i++) {
        echo '<li><a href="#img_' . $i . '">Imagen ' . ($i + 1) . '</a></li>';
    }

    echo '</ul>';

    for ($i=0; $i < count($array); $i++) {

        echo '<div><img id="img_' . $i . '" src="' . $array[$i]['card']['address']['object']['@attributes']['src'] . '" > ' . ($i + 1) . ' - ' . $array[$i]['card']['address']['geo']['@attributes']['latitude'] . ' - ' . $array[$i]['card']['address']['geo']['@attributes']['longitude'] . ' </div>';

    }

?>