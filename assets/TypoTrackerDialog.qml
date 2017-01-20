import bb.system 1.2
import com.canadainc.data 1.0

SystemListDialog
{
    id: typos
    property variant queries: []
    property string tableName
    property variant targetId
    signal correctionsFound(variant ids)
    title: qsTr("Typos") + Retranslate.onLanguageChanged
    body: qsTr("Would you like to track the following to the typos?") + Retranslate.onLanguageChanged
    selectionMode: ListSelectionMode.Multiple
    emoticonsEnabled: false
    selectionIndicator: ListSelectionIndicator.Highlight
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchCorrections && data.length > 0)
        {
            var ids = [];
            
            for (var i = data.length-1; i >= 0; i--) {
                ids.push( data[i].id );
            }
            
            correctionsFound(ids);
            reset();
        }
    }
    
    function reset()
    {
        queries = [];
        clearList();
    }
    
    function record(query)
    {
        var currentQueries = queries;
        currentQueries.push(query);
        queries = currentQueries;
        
        sunnah.fetchCorrections(typos, tableName, query);
    }
    
    function commit(resultId)
    {
        if (queries.length > 0)
        {
            targetId = resultId;
            
            for (var i = 0; i < queries.length; i++) {
                appendItem(queries[i], true, true);
            }
            
            show();
        }
    }
    
    onFinished: {
        if (value == SystemUiResult.ConfirmButtonSelection)
        {
            var selectedQueries = [];
            
            for (var i = 0; i < selectedIndices.length; i++) {
                selectedQueries.push( queries[ selectedIndices[i] ] );
            }
            
            sunnah.addTypos(selectedQueries, targetId, tableName);
            reset();
        }
    }
}