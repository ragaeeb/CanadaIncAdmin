import bb.cascades 1.3

Container
{
    property alias text: textArea.text
    property alias hintText: textArea.hintText
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property string name

    function concat(x)
    {
        var pos = textArea.editor.cursorPosition;
        var prefix = text.substring(0, pos);
        var suffix = text.substring(pos, text.length);
        
        if ( prefix.charAt(prefix.length-1) != ' ' ) {
            prefix += " ";
        }
        
        if ( suffix.charAt(0) != ' ' ) {
            x += " ";
        }
        
        text = prefix+x+suffix;
        
        textArea.requestFocus();
    }

    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    ImageButton
    {
        defaultImageSource: "images/ic_percent.png"
        pressedImageSource: defaultImageSource
        
        onClicked: {
            console.log("UserEvent: Arg"+name);
            concat("%1");
        }
    }
    
    TextArea
    {
        id: textArea
        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
        input.keyLayout: KeyLayout.Text
        leftMargin: 0; bottomMargin: 0; topMargin: 0; leftPadding: 0;
        backgroundVisible: false
        verticalAlignment: VerticalAlignment.Center
        maxHeight: ui.du(20)
        
        gestureHandlers: [
            DoubleTapHandler {
                onDoubleTapped: {
                    console.log("UserEvent: DoubleTapped"+name);
                    concat( persist.getClipboardText() );
                }
            }
        ]
    }
    
    ImageButton
    {
        defaultImageSource: "images/ic_clear.png"
        pressedImageSource: defaultImageSource
        
        onClicked: {
            console.log("UserEvent: Clear"+name);
            textArea.resetText();
            textArea.requestFocus();
        }
    }
}