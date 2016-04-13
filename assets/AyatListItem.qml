import bb.cascades 1.4

StandardListItem
{
    id: rootItem
    description: ListItemData.from_verse_number+"-"+ListItemData.to_verse_number
    imageSource: "images/list/ic_tafsir_ayat.png"
    title: ListItemData.surah_id
    status: ListItemData.id
    
    contextActions: [
        ActionSet
        {
            title: rootItem.title
            subtitle: rootItem.status
            
            ActionItem
            {
                imageSource: "images/menu/ic_edit_link.png"
                title: qsTr("Edit") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: UpdateAyatTafsirLink");
                    rootItem.ListItem.view.updateLink(rootItem.ListItem);
                }
            }
            
            DeleteActionItem
            {
                imageSource: "images/menu/ic_unlink_tafsir_ayat.png"
                title: qsTr("Unlink") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: UnlinkAyatFromTafsir");
                    rootItem.ListItem.view.unlink(rootItem.ListItem);
                }
            }
        }
    ]
}