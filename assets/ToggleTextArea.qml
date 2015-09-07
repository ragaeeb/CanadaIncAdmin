import bb.cascades 1.3

TextField
{
    id: textArea
    property string name
    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
    input.keyLayout: KeyLayout.Text
    
    validator: Validator
    {
        errorMessage: qsTr("Invalid entry for %1").arg(name) + Retranslate.onLanguageChanged
        
        onValidate: {
            valid = text.trim().length == 0 || text.trim().length < 10;
        }
    }
    
    gestureHandlers: [
        DoubleTapHandler {
            onDoubleTapped: {
                console.log("UserEvent: DoubleTapped"+name);
                text = text+" %1 ";
            }
        }
    ]
}