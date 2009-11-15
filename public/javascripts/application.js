// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function update_xml_url() {
    var loc = document.location + ""; /* I can has String::indexOf()? */
    if (loc.indexOf("?") == "-1") {
	document.getElementById("as_xml_url").href=document.location + "?output=xml";
    }
    else {
	document.getElementById("as_xml_url").href=document.location + "&output=xml";
	document.getElementById("as_xml_iframe").src=document.location + "&output=xml";
    }
}

function page_forward() {
    document.getElementById("page").value = "forward";
}

function page_back() {
    document.getElementById("page").value = "back";
}

function page_to_beginning() {
    document.getElementById("page").value = "beginning";
}

function page_to_end() {
    document.getElementById("page").value = "end";
}
    
function onload_app() {
    document.getElementById("page_forward").addEventListener('click',page_forward,true);

    update_xml_url();

}

