<?php

	/* Se descarga el fichero XML de la web opendata.bcn.cat */
	$file = simplexml_load_file("http://opendata.bcn.cat/opendata/es/descarrega-fitxer?url=http%3a%2f%2fbismartopendata.blob.core.windows.net%2fopendata%2fopendata%2f06_2014_XMLOPENDATA.XML&name=XMLOPENDATA.XML");

	//$file = simplexml_load_file("XMLOPENDATA-FULL.XML");

	/* Se convierte el XML a JSON y se guarda en una estructura array */
	$file = json_encode($file,JSON_UNESCAPED_UNICODE);
	$array = json_decode($file,TRUE);
	$file = NULL;

	/* Se duplica la estructura array en la variable obres */
	$array = $array["CA"]["obra"];
	$obres = $array;

	/* Se recorre el array y se eliminan de la estructura obres las que no esten en ejecucion y no sean
	 * obras de tipo Espai Públic
	 */
	for ($i=0; $i < count($array); $i++) {

		$enExecucio = $array[$i]["card"]["status"] !== "En Execució";
		$t = $array[$i]["card"]["worktype"];

		if ( $enExecucio || empty($array[$i]["card"]["worktype"]) || $array[$i]["card"]["worktype"] !== "Espai Públic" )
		{
			unset($obres[$i]);
		}

	}

	$obres = array_values($obres);

	// Es sobreescriu l'arxiu original per el que conté la dada actualitzada
    $fh = fopen("obres.json", 'w')
          or die("Error opening output file");
    fwrite($fh, json_encode($obres,JSON_UNESCAPED_UNICODE));
    fclose($fh);

    echo 'Fitxer obres.json actualitzat!';

?>