// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function update_xml_url() {
    var loc = document.location + ""; /* I can has indexOf()? */
    if (loc.indexOf("?") == "-1") {
	document.getElementById("as_xml_url").href=document.location + "?output=xml";
    }
    else {
	document.getElementById("as_xml_url").href=document.location + "&output=xml";
    }
}