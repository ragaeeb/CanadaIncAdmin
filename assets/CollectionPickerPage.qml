import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: root
    function cleanUp() {}
    signal picked(variant selectedIds)
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllCollections) {
            adm.append(data);
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        ListView
        {
            id: listView
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        imageSource: "images/list/ic_book.png"
                        title: ListItemData.name
                        
                        contextActions: [
                            ActionSet {}
                        ]
                    }
                }
            ]
            
            multiSelectHandler.actions: [
                ActionItem
                {
                    imageSource: "images/menu/ic_accept.png"
                    title: qsTr("Accept") + Retranslate.onLanguageChanged
                    
                    onTriggered: {
                        var all = listView.selectionList();
                        var result = [];
                        
                        for (var i = all.length-1; i >= 0; i--) {
                            result.push( adm.data(all[i]) );
                        }
                        
                        picked(result);
                    }
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: CollectionTapped");
                picked( [ dataModel.data(indexPath) ] );
            }
        }
    }
    
    onCreationCompleted: {
        sunnah.fetchAllCollections(root);
    }
}