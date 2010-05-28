// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
var alternativeCounter = 0;

/**
 * Adds a <li><input /></li> to the end of the given ul.
 * @param ulId id of the ul where the row is added
 * @parma inputName name of the input to add. [n] is added automatically.
 */
function addTextfieldRow(ulId, inputName) {
  ulElement = $(ulId);
  i = ulElement.select("input").length;
  
  ulElement.insert({
    bottom: "<li><input type='text' name='"+inputName+"[" + i + "]' /></li>"
  });
}
