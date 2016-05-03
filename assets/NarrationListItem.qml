import bb.cascades 1.4

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    
    Header {
        title: ListItemData.name
        subtitle: ListItemData.hadith_number
    }
    
    Container
    {
        leftPadding: 10; rightPadding: 10; bottomPadding: 5; topPadding: 5
        horizontalAlignment: HorizontalAlignment.Fill
        
        Label {
            id: bodyLabel
            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
            multiline: true
            text: ListItemData.body
        }
    }
}