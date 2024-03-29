import bb.cascades 1.2

QtObject
{
    property variant individualImageMap: {'1': "images/list/ic_companion.png", '2': "images/dropdown/ic_tabiee.png", '3': "images/dropdown/ic_tabi_tabiee.png", '4': "images/dropdown/ic_scholar.png", '5': "images/dropdown/ic_student_knowledge.png"}
    
    function extractADM(adm)
    {
        var result = [];
        var n = adm.size();
        
        for (var i = 0; i < n; i++) {
            result.push( adm.value(i) );
        }
        
        return result;
    }
    
    
    function getImageFor(companionId)
    {
        var value = individualImageMap[ companionId.toString() ];
        return value ? value : "images/list/ic_individual.png";
        return value;
    }
    
    
    function extractTokens(trimmed)
    {
        var elements = trimmed.match(/(?:[^\s"]+|"[^"]*")+/g);
        
        for (var j = elements.length-1; j >= 0; j--) {
            elements[j] = elements[j].replace(/^"(.*)"$/, '$1');
        }
        
        return elements;
    }

    function endsWith(str, suffix) {
        return str.indexOf(suffix, str.length - suffix.length) !== -1;
    }
    
    function stripSlashFromClipboard()
    {
        var input = persist.getClipboardText().trim();
        
        if ( endsWith(input, "/") ) {
            return input.substring(0, input.length-1);
        }
        
        return input;
    }
    
    function optimizeAndClean(input)
    {
        var n = invokeHelper.optimize(input);
        n = offloader.toTitleCase(n);
        n = n.replace(/\-[A-Z]{1}[a-z]{1}\-/, function(v) {
            return v.toLowerCase();
        });

        return n;
    }
    
    function applySelectionToDropdown(dropdown, value)
    {
        for (var i = dropdown.count()-1; i >= 0; i--)
        {
            if ( dropdown.at(i).value == value ) {
                dropdown.selectedIndex = i;
                break;
            }
        }
    }
    
    function plainText(input) {
        return input.replace(/<[^>]*>/gi, "");
    }
    
    function getCapitalizedClipboard()
    {
        var x = persist.getClipboardText();
        x = x.charAt(0).toUpperCase() + x.slice(1); 
        return x;
    }
}