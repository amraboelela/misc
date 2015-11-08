//
// toggle section, and if close, then open and close all count siblings
//
function toggle(prefix, index, count)
{
	var div = document.getElementById('d' + prefix + index);
	var button = document.getElementById('b' + prefix + index);
	if (div.style.display == 'block')
	{
		div.style.display = 'none';
		button.src = 'images/plus.png';
	}
	else
	{
		div.style.display = 'block';
		button.src = 'images/minus.png';
		for (var i = 1; i <= count; i++)
			if (i != index)
				close(prefix + i);
	}
	var position = 0;
	position += parseInt(index);
	var splitArray = prefix.split('-');
	for (var i = 0; i < splitArray.length; i++)
	{
		position += splitArray[i] - 0;
		//alert('position: ' + position);
	}
	window.scrollTo(0, position * 17 - 20);
}

//
// close this section with id ID
//
function close(ID)
{
	var div = document.getElementById('d' + ID);
	var button = document.getElementById('b' + ID);
	if (div)
	{
		div.style.display = 'none';
		button.src = 'images/plus.png';
	}
}

//
// open this section with id ID
//
function open(ID)
{
	//alert("open " + ID);
	var div = document.getElementById('d' + ID);
	var button = document.getElementById('b' + ID);
	if (div)
	{
		div.style.display = 'block';
		button.src = 'images/minus.png';
	}
}

//
// search for str
//
function searchPrompt()
{
	defaultText = "";
	promptText = "Please enter the words you'd like to search for, separated by spaces:";
	txtSearch = prompt(promptText, defaultText);
	if (!txtSearch)
	{
		//alert("No search terms were entered. Exiting function.");
		return false;
	}
	//alert('searching for: ' + txtSearch.value);
	document.body.innerHTML = originalBodyText;
	var divs = document.getElementsByTagName("div");
	var searchArray = txtSearch.toLowerCase().split(" ");
	for (var i=0; i < divs.length; i++)
	{
		//alert('div: ' + divs[i].id);
		if (divs[i].id.indexOf('d') == 0)
		{
			//alert('it is section!' + divs[i].id);
			for (var j=0; j<searchArray.length; j++)
			{
				//alert(searchArray[j]);
 				if (divs[i].innerHTML.toLowerCase().indexOf(searchArray[j]) > -1)
					open(divs[i].id.substring(1));
			}
		}
	}
	highlightSearchTerms(txtSearch);
}

var originalBodyText;

//
// init
//
function init()
{
	originalBodyText = document.body.innerHTML;
	//alert("init: " + originalBodyText);
}

String.prototype.trim = function () 
{
	return this.replace("/^\s+|\s+$/g", "");
}

//
// highlight search terms
//
function highlightSearchTerms(searchText)
{
	if (searchText.trim() == "")
		return;
	//alert("highlightSearchTerms: " + searchText);
	// We will split the search string so that each word is searched for and highlighted individually
	var searchArray = searchText.split(" ");
	
	if (!document.body || typeof(document.body.innerHTML) == "undefined") 
	{
		alert("error");
		return false;
	}
	var bodyText = document.body.innerHTML;
	for (var i=0; i<searchArray.length; i++)
		bodyText = doHighlight(bodyText, searchArray[i]);
	document.body.innerHTML = bodyText;
	return true;
}

//
// This is the function that actually highlights a text string by
// adding HTML tags before and after all occurrences of the search term.
//
function doHighlight(bodyText, searchTerm) 
{
	var highlightStartTag = "<font style='background-color:yellow;'>";
	var highlightEndTag = "</font>";
	
	// find all occurences of the search term in the given text,
	// and add some "highlight" tags to them (we're not using a
	// regular expression search, because we want to filter out
	// matches that occur within HTML tags and script blocks, so
	// we have to do a little extra validation)
	var newText = "";
	var i = -1;
	var lcSearchTerm = searchTerm.toLowerCase();
	var lcBodyText = bodyText.toLowerCase();
		
	while (bodyText.length > 0) 
	{
		i = lcBodyText.indexOf(lcSearchTerm, i+1);
		if (i < 0) 
		{
			newText += bodyText;
			bodyText = "";
		} 
		else 
		{
			// skip anything inside an HTML tag
			if (bodyText.lastIndexOf(">", i) >= bodyText.lastIndexOf("<", i))
			{
				// skip anything inside a <script> block
				if (lcBodyText.lastIndexOf("/script>", i) >= lcBodyText.lastIndexOf("<script", i)) 
				{
					newText += bodyText.substring(0, i) + highlightStartTag + bodyText.substr(i, searchTerm.length) + highlightEndTag;
					bodyText = bodyText.substr(i + searchTerm.length);
					lcBodyText = bodyText.toLowerCase();
					i = -1;
					//alert("newText " + newText);
				}
			}
		}
	}
	return newText;
}

function txt_search_keydown(currentFrame,keyEvent)
{   
        if (keyEvent.keyCode == 13)
                currentFrame.document.all.btn_search.focus();
}
