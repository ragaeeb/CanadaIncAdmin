import QtQuick 1.0
import bb.cascades 1.3
import bb.system 1.2
import com.canadainc.data 1.0

Page
{
    id: createRijaal
    property alias name: tftk.textField
    property variant individualId
    signal createIndividual(variant id, string prefix, string name, string kunya, string displayName, bool hidden, int birth, int death, bool female, variant location, variant currentLocation, int level, string description)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarFollowKeyboardPolicy: ActionBarFollowKeyboardPolicy.Never
    
    onIndividualIdChanged: {
        if (individualId) {
            ilmHelper.fetchIndividualData(createRijaal, individualId);
        }
    }
    
    function cleanUp() {}
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchIndividualData && results.length > 0)
        {
            var data = results[0];
            
            hidden.checked = data.hidden == 1;
            female.checked = data.female == 1;
            var levelValue = data.is_companion;
            
            for (var i = level.count()-1; i >= 0; i--)
            {
                if ( level.at(i).value == levelValue ) {
                    level.selectedIndex = i;
                    break;
                }
            }

            name.text = data.name;
            
            if (data.prefix) {
                prefix.text = data.prefix;
            }
            
            if (data.kunya) {
                kunya.text = data.kunya;
            }
            
            if (data.birth) {
                birth.text = data.birth.toString();
            }
            
            if (data.death) {
                death.text = data.death.toString();
            }
            
            if (data.displayName) {
                displayName.text = data.displayName;
            }
            
            if (data.location) {
                location.pickedId = data.location;
            }
            
            if (data.current_location) {
                currentLocation.pickedId = data.current_location;
            }
            
            if (data.notes) {
                descriptionField.text = data.notes;
            }
        }
    }
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk

            textField {
                hintText: qsTr("Name...") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                input.keyLayout: KeyLayout.Contact
                inputMode: TextFieldInputMode.Text
                input.submitKey: SubmitKey.Next
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                
                validator: Validator
                {
                    errorMessage: qsTr("Invalid name") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: { 
                        valid = name.text.trim().length > 3;
                    }
                }
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: IndividualNameDoubleTapped");
                            var n = global.optimizeAndClean( persist.getClipboardText().replace(/,/g, "") );
                            var x = offloader.parseName(n);
                            
                            if (x.name) {
                                var nameValue = x.name;
                                name.text = nameValue.charAt(0).toUpperCase() + nameValue.slice(1);
                            }
                            
                            if (x.kunya) {
                                kunya.text = x.kunya;
                            }
                            
                            if (x.prefix) {
                                prefix.text = x.prefix;
                            }
                            
                            if (x.death) {
                                death.text = x.death;
                            }
                        }
                    }
                ]
            }
        }
        
        dismissAction: ActionItem
        {
            id: saveAction
            imageSource: "images/dropdown/ic_save_individual.png"
            title: qsTr("Save") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: SaveIndividual");
                
                name.validator.validate();
                
                if (name.validator.valid) {
                    createIndividual(individualId, prefix.text.trim(), name.text.trim(), kunya.text.trim(), displayName.text.trim(), hidden.checked, parseInt( birth.text.trim() ), parseInt( death.text.trim() ), female.checked, location.pickedId, currentLocation.pickedId, level.selectedValue, descriptionField.text.trim() );
                } else {
                    persist.showToast( qsTr("Invalid name!"), "images/toast/invalid_name.png" );
                }
            }
        }
    }

    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        ScrollView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            Container
            {
                topPadding: 10
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                DropDown
                {
                    id: level
                    horizontalAlignment: HorizontalAlignment.Fill
                    topMargin: 0; bottomMargin: 0
                    
                    Option {
                        id: noneOption
                        imageSource: "images/dropdown/ic_individual_none.png"
                        description: qsTr("Unclassified") + Retranslate.onLanguageChanged
                        text: qsTr("None") + Retranslate.onLanguageChanged
                        value: undefined
                        selected: true
                    }
                    
                    Option {
                        id: companionOption
                        imageSource: "images/dropdown/ic_companion.png"
                        description: qsTr("Companion") + Retranslate.onLanguageChanged
                        text: qsTr("Sahabah") + Retranslate.onLanguageChanged
                        value: 1
                    }
                    
                    Option {
                        id: tabiOption
                        imageSource: "images/dropdown/ic_tabiee.png"
                        description: qsTr("Students of the Companions") + Retranslate.onLanguageChanged
                        text: qsTr("Tabi'ee") + Retranslate.onLanguageChanged
                        value: companionOption.value+1
                    }
                    
                    Option {
                        id: tabiTabiOption
                        imageSource: "images/dropdown/ic_tabi_tabiee.png"
                        description: qsTr("Students of the Students of the Companions") + Retranslate.onLanguageChanged
                        text: qsTr("Tabi' Tabi'een") + Retranslate.onLanguageChanged
                        value: tabiOption.value+1
                    }
                    
                    Option {
                        id: scholarOption
                        imageSource: "images/dropdown/ic_scholar.png"
                        description: qsTr("Mashaykh") + Retranslate.onLanguageChanged
                        text: qsTr("Scholar") + Retranslate.onLanguageChanged
                        value: tabiTabiOption.value+1
                    }
                    
                    Option {
                        id: tullab
                        imageSource: "images/dropdown/ic_student_knowledge.png"
                        description: qsTr("Student of Knowledge") + Retranslate.onLanguageChanged
                        text: qsTr("Taalib'ul Ilm") + Retranslate.onLanguageChanged
                        value: scholarOption.value+1
                    }
                }
                
                TextField
                {
                    id: displayName
                    hintText: qsTr("Display Name...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    input.keyLayout: KeyLayout.Contact
                    inputMode: TextFieldInputMode.Text
                    input.submitKey: SubmitKey.Next
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                    bottomMargin: 10; topMargin: 10
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: DisplayNameDoubleTapped");
                                displayName.text = global.optimizeAndClean( persist.getClipboardText() );
                            }
                        }
                    ]
                }
                
                Container
                {
                    leftPadding: 10; rightPadding: 10
                    
                    Container
                    {
                        layout: StackLayout {
                            orientation: LayoutOrientation.LeftToRight
                        }
                        
                        CheckBox {
                            id: female
                            text: qsTr("Female") + Retranslate.onLanguageChanged
                        }
                        
                        CheckBox {
                            id: hidden
                            text: qsTr("Hidden") + Retranslate.onLanguageChanged
                            verticalAlignment: VerticalAlignment.Center
                        }
                    }
                }
                
                Container
                {
                    topMargin: 10
                    
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    TextField
                    {
                        id: prefix
                        hintText: qsTr("Prefix (ie: al-Hafidh, Shaykh)") + Retranslate.onLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Fill
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                        input.submitKey: SubmitKey.Next
                        input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                        
                        gestureHandlers: [
                            DoubleTapHandler {
                                onDoubleTapped: {
                                    console.log("UserEvent: PrefixDoubleTapped");
                                    prefix.text = offloader.toTitleCase( persist.getClipboardText() );
                                }
                            }
                        ]
                    }
                    
                    TextField
                    {
                        id: kunya
                        hintText: qsTr("Kunya...") + Retranslate.onLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Fill
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                        input.submitKey: SubmitKey.Next
                        input.keyLayout: KeyLayout.Contact
                        inputMode: TextFieldInputMode.Text
                        input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                        
                        gestureHandlers: [
                            DoubleTapHandler {
                                onDoubleTapped: {
                                    console.log("UserEvent: IndividualKunyaDoubleTapped");
                                    kunya.text = offloader.toTitleCase( persist.getClipboardText() );
                                }
                            }
                        ]
                    }
                }
                
                Header {
                    topMargin: 10
                    title: location.focused ? location.hintText : currentLocation.focused ? currentLocation.hintText : qsTr("Historical Information") + Retranslate.onLanguageChanged
                }
                
                Container
                {
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
                    }
                    
                    TextField
                    {
                        id: birth
                        hintText: qsTr("Birth (AH)...") + Retranslate.onLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Fill
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                        inputMode: TextFieldInputMode.NumbersAndPunctuation
                        maximumLength: 4
                        input.submitKey: SubmitKey.Next
                        input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 0.2
                        }
                        
                        gestureHandlers: [
                            DoubleTapHandler {
                                onDoubleTapped: {
                                    console.log("UserEvent: BirthDoubleTapped");
                                    birth.text = persist.getClipboardText();
                                }
                            }
                        ]
                    }
                    
                    TextField
                    {
                        id: death
                        hintText: qsTr("Death (AH)...") + Retranslate.onLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Fill
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                        inputMode: TextFieldInputMode.NumbersAndPunctuation
                        maximumLength: 4
                        input.submitKey: SubmitKey.Next
                        input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 0.2
                        }
                        
                        gestureHandlers: [
                            DoubleTapHandler {
                                onDoubleTapped: {
                                    console.log("UserEvent: DeathDoubleTapped");
                                    death.text = persist.getClipboardText();
                                }
                            }
                        ]
                    }
                    
                    LocationField
                    {
                        id: location
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 0.3
                        }
                    }
                    
                    LocationField
                    {
                        id: currentLocation
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 0.3
                        }
                    }
                }
                
                TextArea {
                    id: descriptionField
                    hintText: qsTr("Description...") + Retranslate.onLanguageChanged
                    minHeight: ui.sdu(18.75)
                    inputMode: TextAreaInputMode.Text
                    content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                    input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                console.log("UserEvent: IndividualDescDoubleTapped");
                                descriptionField.text = invokeHelper.optimize( persist.getClipboardText() );
                            }
                        },
                        
                        PinchHandler {
                            onPinchEnded: {
                                if (event.pinchRatio < 1) {
                                    console.log("UserEvent: PasteDescription");
                                    descriptionField.text = descriptionField.text+"\n\n"+invokeHelper.optimize( persist.getClipboardText() );
                                }
                            }
                        }
                    ]
                }
            }
        }
    }
    
    attachedObjects: [
        Timer {
            interval: 250
            running: true
            repeat: false
            
            onTriggered: {
                if (!individualId) {
                    name.requestFocus();
                }
            }
        }
    ]
}