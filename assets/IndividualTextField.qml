import bb.cascades 1.3

TextField
{
    id: tf
    property string table: "suites"
    property string field: "author"
    horizontalAlignment: HorizontalAlignment.Fill
    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
    input.keyLayout: KeyLayout.NumbersAndPunctuation
    
    validator: Validator
    {
        id: numericValidator
        errorMessage: qsTr("Only digits can be entered!") + Retranslate.onLanguageChanged
        mode: ValidationMode.FocusLost
        
        onValidate: {
            valid = /^\d+$/.test( tf.text.trim() );
        }
    }
    
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
                ilmHelper.fetchFrequentIndividuals(p.pickerList, table, field);
                
                navigationPane.push(p);
            }
        }
    ]
}