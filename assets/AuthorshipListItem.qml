import bb.cascades 1.0

StandardListItem
{
    id: workSli
    description: ListItemData.title
    imageSource: "images/list/ic_book.png"
    title: ListItemData.author ? ListItemData.author : ListItemData.reference ? ListItemData.reference : ""
    
    contextActions: [
        ActionSet
        {
            title: workSli.title
            
            ActionItem
            {
                imageSource: "images/menu/ic_edit_bio.png"
                title: qsTr("Edit") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: EditBio");
                    workSli.ListItem.view.editBio(workSli.ListItem, ListItemData);
                }
            }
        }
    ]
}