import bb.cascades 1.4

Container
{
    horizontalAlignment: HorizontalAlignment.Fill
    leftPadding: 10; rightPadding: 10; bottomPadding: 10
    
    Label {
        id: bodyLabel
        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
        multiline: true
        text: ListItemData.body+" ("+ListItemData.name+" #"+ListItemData.hadith_number+")"
    }
    
    Divider {
        topMargin: 0; bottomMargin: 0;
    }
}