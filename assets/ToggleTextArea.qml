import bb.cascades 1.3

Container
{
    property alias text: textArea.text
    property alias hintText: textArea.hintText
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    property string name
    property bool symbolEnabled: true
    property bool percentExists: false
    property string symbolValue: "%1"

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
        
        prefix = prefix+x+suffix;
        text = prefix.trim();
        
        textArea.requestFocus();
    }

    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    ImageButton
    {
        id: symbol
        defaultImageSource: "images/ic_percent.png"
        disabledImageSource: defaultImageSource
        pressedImageSource: defaultImageSource
        verticalAlignment: VerticalAlignment.Center
        enabled: !percentExists && symbolEnabled
        opacity: enabled ? 1 : 0.5
        
        onClicked: {
            console.log("UserEvent: Arg"+name);
            concat(symbolValue);
        }
    }
    
    TextArea
    {
        id: textArea
        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
        input.keyLayout: KeyLayout.Text
        leftMargin: 0; bottomMargin: 0; topMargin: 0; leftPadding: 0;
        backgroundVisible: false
        verticalAlignment: VerticalAlignment.Center
        maxHeight: ui.du(20)
        
        onTextChanged: {
            percentExists = text.indexOf(symbolValue) >= 0;
        }
        
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
        verticalAlignment: VerticalAlignment.Center
        
        onClicked: {
            console.log("UserEvent: Clear"+name);
            textArea.resetText();
            textArea.requestFocus();
        }
    }
}