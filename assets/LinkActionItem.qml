import bb.cascades 1.4
import com.canadainc.data 1.0

ActionItem
{
    id: linkAction
    imageSource: "images/menu/ic_link.png"
    title: qsTr("Link") + Retranslate.onLanguageChanged
    property variant selectedIds: []
    property variant cached
    property int nextGroupNumber: 0
    
    function createNewGroup() {
        sunnah.groupNarrations(linkAction, selectedIds, nextGroupNumber);
    }
    
    function onPicked(id)
    {
        if (id != 0) {
            sunnah.groupNarrations(linkAction, selectedIds, id);
        } else {
            createNewGroup();
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchGroupedNarrations)
        {
            if (data.length > 0) { // at least one of these narrations already belongs to a group, ask user if they want to merge these new narrations into one of the existing groups or not
                var ngp = Qt.launch("NarrationGroupPicker.qml");
                ngp.picked.connect(onPicked);
                ngp.apply(data);
            } else { // these narrations don't already belong to a group, create a new one
                createNewGroup();
            }
        } else if (id == QueryId.FetchNextGroupNumber) {
            nextGroupNumber = data[0].group_number ? data[0].group_number : 1;
            console.log("NextGroupNumberAvailable", nextGroupNumber);
        } else if (id == QueryId.GroupNarrations) {
            persist.showToast( qsTr("Narrations successfully linked!"), linkAction.imageSource.toString() );
            
            for (var i = cached.length-1; i >= 0; i--)
            {
                var current = listView.dataModel.data(cached[i]);
                
                if (!current.group_id)
                {
                    current.group_id = nextGroupNumber;
                    listView.dataModel.replace(cached[i], current);
                }
            }
            
            popToRoot();
        }
    }
    
    onTriggered: {
        console.log("UserEvent: LinkNarrations");
        
        var all = listView.selectionList();
        var result = [];
        
        for (var i = all.length-1; i >= 0; i--) {
            result.push( listView.dataModel.data(all[i]).narration_id );
        }
        
        selectedIds = result;
        cached = all;
        sunnah.fetchNextAvailableGroupNumber(linkAction);
        sunnah.fetchGroupedNarrations(linkAction, result);
    }
}