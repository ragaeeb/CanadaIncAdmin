import bb.cascades 1.3

TextArea
{
    id: textArea
    property string name
    editable: false
    minHeight: ui.du(18.75)
    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
    input.keyLayout: KeyLayout.Text
    inputMode: TextAreaInputMode.Text
    
    function validate()
    {
        if ( text.trim().length > 0 && text.trim().length <= 10 )
        {
            persist.showToast( qsTr("Invalid entry for %1!").arg(name), "asset:///images/toast/question_entry_warning.png" );
            return false;
        }
        
        return true;
    }
    
    gestureHandlers: [
        TapHandler {
            onTapped: {
                textArea.editable = !textArea.editable;
                console.log("UserEvent: Tap%1".arg(name), textArea.editable);
            }
        }
    ]
}