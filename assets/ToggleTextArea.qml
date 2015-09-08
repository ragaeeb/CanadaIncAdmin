import bb.cascades 1.3

Container
{
    property alias text: textArea.text
    property alias hintText: textArea.hintText
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property string name

    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    ImageButton
    {
        defaultImageSource: "images/menu/ic_copy.png"
        pressedImageSource: defaultImageSource
        
        onClicked: {
            console.log("UserEvent: ArgButtonClicked");
            
            if ( text.charAt(text.length-1) == ' ' ) {
                text = text+"%1 ";
            } else {
                text = text+" %1 ";
            }
        }
    }
    
    TextField
    {
        id: textArea
        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
        input.keyLayout: KeyLayout.Text
        leftMargin: 0; bottomMargin: 0; topMargin: 0; leftPadding: 0;
        backgroundVisible: false
        verticalAlignment: VerticalAlignment.Center
        
        validator: Validator
        {
            errorMessage: qsTr("Invalid entry for %1").arg(name) + Retranslate.onLanguageChanged
            
            onValidate: {
                valid = text.trim().length == 0 || text.trim().length > 10;
            }
        }
        
        gestureHandlers: [
            DoubleTapHandler {
                onDoubleTapped: {
                    console.log("UserEvent: DoubleTapped"+name);
                    text = text+persist.getClipboardText();
                }
            }
        ]
    }
}