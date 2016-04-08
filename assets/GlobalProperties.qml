import bb.cascades 1.2

QtObject
{
    function extractADM(adm)
    {
        var result = [];
        var n = adm.size();
        
        for (var i = 0; i < n; i++) {
            result.push( adm.value(i) );
        }
        
        return result;
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
    
    function getCapitalizedClipboard()
    {
        var x = persist.getClipboardText();
        x = x.charAt(0).toUpperCase() + x.slice(1); 
        return x;
    }
}