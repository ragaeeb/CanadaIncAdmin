import bb.cascades 1.4
import com.canadainc.data 1.0

ActionItem
{
    id: linkAction
    imageSource: "images/menu/ic_link.png"
    title: qsTr("Link") + Retranslate.onLanguageChanged
    property variant selectedIds: []
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
                definition.source = "NarrationGroupPicker.qml";
                var ngp = definition.createObject();
                ngp.picked.connect(onPicked);
                ngp.apply(data);
                
                navigationPane.push(ngp);
            } else { // these narrations don't already belong to a group, create a new one
                createNewGroup();
            }
        } else if (id == QueryId.FetchNextGroupNumber) {
            nextGroupNumber = data[0].group_number ? data[0].group_number : 1;
            console.log("NextGroupNumberAvailable", nextGroupNumber);
        } else if (id == QueryId.GroupNarrations) {
            persist.showToast( qsTr("Narrations successfully linked!"), linkAction.imageSource.toString() );
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
        sunnah.fetchNextAvailableGroupNumber(linkAction);
        sunnah.fetchGroupedNarrations(linkAction, result);
    }
    
    attachedObjects: [
        ComponentDefinition
        {
            id: pickerDef
            
            Page
            {
                id: pickerPage
                signal picked(int id)
                
                function cleanUp() {}
                
                titleBar: TitleBar {
                    title: qsTr("Select Group") + Retranslate.onLanguageChanged
                }
                
                function apply(data)
                {
                    gdm.clear();
                    gdm.insertList(data);
                }
                
                actions: [
                    ActionItem
                    {
                        id: newGroup
                        imageSource: "images/menu/ic_new_group.png"
                        title: qsTr("New") + Retranslate.onLanguageChanged
                        ActionBar.placement: ActionBarPlacement.Signature
                        
                        onTriggered: {
                            console.log("UserEvent: NewGroup");
                            pickerPage.picked(0);
                        }
                    }
                ]
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    layout: DockLayout {}
                    
                    ListView
                    {
                        id: listView
                        scrollRole: ScrollRole.Main
                        
                        dataModel: GroupDataModel
                        {
                            id: gdm
                            grouping: ItemGrouping.ByFullValue
                            sortingKeys: ["group_number", "name", "hadith_number"]
                        }
                        
                        listItemComponents: [
                            ListItemComponent
                            {
                                type: "header"
                                
                                Header {
                                    title: ListItemData.toString()
                                }
                            },

                            ListItemComponent
                            {
                                type: "item"
                                NarrationListItem {}
                            }
                        ]

                        onTriggered: {
                            console.log("UserEvent: SimilarHadithTap");
                            
                            if (indexPath.length > 1) {
                                pickerPage.picked( dataModel.data(indexPath).group_number );
                            }
                        }
                    }
                }
            }
        }
    ]
}