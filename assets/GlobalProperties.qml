import bb.cascades 1.2

QtObject
{
    function getHijriYear(y1, y2)
    {
        if (y1 > 0 && y2 > 0) {
            return qsTr("%1-%2 AH").arg(y1).arg(y2);
        } else if (y1 < 0 && y2 < 0) {
            return qsTr("%1-%2 BH").arg( Math.abs(y1) ).arg( Math.abs(y2) );
        } else if (y1 < 0 && y2 > 0) {
            return qsTr("%1 BH - %2 AH").arg( Math.abs(y1) ).arg(y2);
        } else {
            return y1 > 0 ? qsTr("%1 AH").arg(y1) : qsTr("%1 BH").arg( Math.abs(y1) );
        }
    }
    
    function optimizeAndClean(input)
    {
        var n = textUtils.optimize(input);
        n = textUtils.toTitleCase(n);
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