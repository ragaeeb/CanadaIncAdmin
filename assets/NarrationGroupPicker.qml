import bb.cascades 1.4

Page
{
    signal picked(int id)
    
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
                picked(0);
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
                    picked( dataModel.data(indexPath).group_number );
                }
            }
        }
    }
}