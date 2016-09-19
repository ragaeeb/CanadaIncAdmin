import bb.cascades 1.0

StandardListItem
{
    id: rootSli
    property alias delImage: delAction.imageSource
    title: ListItemData.name
    
    contextActions: [
        ActionSet
        {
            title: rootSli.title
            
            DeleteActionItem
            {
                id: delAction
                
                onTriggered: {
                    console.log("UserEvent: RemoveTeacher");
                    rootSli.ListItem.view.removeRelation(rootSli.ListItem, ListItemData);
                }
            }
        }
    ]
}