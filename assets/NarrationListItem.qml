import bb.cascades 1.0

Container
{
    id: rootItem
    property alias labelBackground: labelContainer.background
    horizontalAlignment: HorizontalAlignment.Fill
    
    Header
    {
        id: header
        title: ListItemData.name
        subtitle: ListItemData.hadith_number
    }
    
    Container
    {
        id: labelContainer
        leftPadding: 10; rightPadding: 10; bottomPadding: 5; topPadding: 5
        horizontalAlignment: HorizontalAlignment.Fill
        
        Label {
            id: bodyLabel
            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
            multiline: true
            text: ListItemData.body
        }
    }
    
    contextActions: [
        ActionSet
        {
            title: ListItemData.name
            subtitle: ListItemData.body.substring( 0, Math.min(ListItemData.body.length, 15) ).replace(/\n/g, " ")
            
            ActionItem
            {
                imageSource: "images/menu/ic_preview_hadith.png"
                title: qsTr("Open") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    rootItem.ListItem.view.openNarration(ListItemData);
                }
            }
        }
    ]
}