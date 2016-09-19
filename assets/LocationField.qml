import bb.cascades 1.3

TextField
{
    id: location
    horizontalAlignment: HorizontalAlignment.Fill
    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
    input.submitKey: SubmitKey.Search
    input.keyLayout: KeyLayout.Text
    inputMode: TextFieldInputMode.Text
    property string userEvent
    
    input.onSubmitted: {
        console.log( "UserEvent: %1".arg(userEvent) );
        location.validator.validate();
    }
    
    validator: Validator
    {
        errorMessage: qsTr("No locations found...") + Retranslate.onLanguageChanged;
        mode: ValidationMode.Custom
        
        function parseCoordinate(input)
        {
            var tokens = input.trim().split(" ");
            var value = parseFloat( tokens[0].trim() );
            
            if ( tokens[1].trim() == "S" || tokens[1].trim() == "W") {
                value *= -1;
            }
            
            return value;
        }
        
        onValidate: {
            var trimmed = location.text.trim();
            
            if (trimmed.length == 0) {
                valid = true;
            } else {
                if ( trimmed.match("\\d.+\\s[NS]{1},\\s+\\d.+\\s[EW]{1}") )
                {
                    createLocationPicker(dth);
                    var tokens = trimmed.split(",");
                    app.geoLookup( parseCoordinate(tokens[0]), parseCoordinate(tokens[1]) );
                } else if ( trimmed.match("-{0,1}\\d.+,\\s+-{0,1}\\d.+") ) {
                    createLocationPicker(dth);
                    var tokens = trimmed.split(",");
                    app.geoLookup( parseFloat( tokens[0].trim() ), parseFloat( tokens[1].trim() ) );
                } else if ( trimmed.match("\\d+$") ) {
                    valid = true;
                } else {
                    createLocationPicker(dth);
                    app.geoLookup(trimmed);
                }
            }
        }
    }
    
    gestureHandlers: [
        DoubleTapHandler
        {
            id: dth
            
            function onPicked(id, name)
            {
                location.text = id.toString();
                location.hintText = name;
                Qt.navigationPane.pop();
            }
            
            onDoubleTapped: {
                console.log("UserEvent: LocationFieldDoubleTapped");
                var p = createLocationPicker(dth);
                p.performSearch();
            }
        }
    ]
}