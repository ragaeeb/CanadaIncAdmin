import bb.cascades 1.0

TextField
{
    id: tf
    property string table: "suites"
    property string field: "author"
    horizontalAlignment: HorizontalAlignment.Fill
    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
    
    gestureHandlers: [
        DoubleTapHandler
        {
            function onPicked(id)
            {
                tf.text = id.toString();
                navigationPane.pop();
            }
            
            onDoubleTapped: {
                console.log("UserEvent: AuthorDoubleTapped");
                definition.source = "IndividualPickerPage.qml";

                var p = definition.createObject();
                p.picked.connect(onPicked);
                tafsirHelper.fetchFrequentIndividuals(p.pickerList, table, field);
                
                navigationPane.push(p);
            }
        }
    ]
}