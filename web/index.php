<?php
$resFile = 'Steps.xml';

$version = empty($_GET['format']) ? "html" : strtolower($_GET['format']);

if ($version == "rss") {
	header("Content-type: application/xml");
} elseif ($version == "html") {
	readfile("angular.html");
	exit;
}

$xslFile = "Steps.$version.xsl";

$xp = new XsltProcessor();

$xsl = new DomDocument;
$xsl->load($xslFile);

$xp->importStylesheet($xsl);

$xml_doc = new DomDocument;
$xml_doc->load($resFile);

if ($html = $xp->transformToXML($xml_doc)) {
	echo $html;
} else {
	trigger_error('XSL transformation failed.', E_USER_ERROR);
} // if

?>
