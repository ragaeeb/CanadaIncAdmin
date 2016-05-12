import bb.cascades 1.4
import com.canadainc.data 1.0

ActionItem
{
    id: linkChoices
    enabled: false
    imageSource: "images/menu/ic_link_choices.png"
    property variant chosen
    property string key: "id"
    title: qsTr("Group") + Retranslate.onLanguageChanged
    
    function onPicked(tagObj) {
        ilmTest.tagChoices(linkChoices, chosen, tagObj.tag);
        navigationPane.pop();
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchTagsForChoices)
        {
            definition.source = "TagPickerPage.qml";
            var x = definition.createObject();
            x.prepopulated = data;
            x.table = "grouped_choices";
            x.picked.connect(onPicked);
            
            navigationPane.push(x);
        } else if (id == QueryId.TagChoices) {
            persist.showToast( qsTr("Tagged choices!"), imageSource.toString() );
        }
    }
    
    onTriggered: {
        console.log("UserEvent: GroupChoices");
        
        var all = listView.selectionList();
        var result = [];
        
        for (var i = all.length-1; i >= 0; i--)
        {
            var d = adm.data(all[i]);
            
            if ( !d.source_id || d.source_id.toString().length == 0 ) {
                result.push(d[key]);
            }
        }
        
        if (result.length > 0)
        {
            chosen = result;
            ilmTest.fetchTagsForChoices(linkChoices, result);
        }
    }
}