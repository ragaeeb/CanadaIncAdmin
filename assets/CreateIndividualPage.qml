import QtQuick 1.0
import bb.cascades 1.3
import bb.system 1.2
import com.canadainc.data 1.0

Page
{
    id: createRijaal
    property alias name: tftk.textField
    property variant individualId
    signal createIndividual(variant id, string prefix, string name, string kunya, string displayName, bool hidden, int birth, int death, bool female, variant location, int level)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    actionBarFollowKeyboardPolicy: ActionBarFollowKeyboardPolicy.Never
    
    onIndividualIdChanged: {
        if (individualId)
        {
            tafsirHelper.fetchIndividualData(createRijaal, individualId);
            tafsirHelper.fetchAllWebsites(createRijaal, individualId);
        }
    }
    
    function cleanUp() {}
    
    actions: [
        ActionItem
        {
            id: addSite
            imageSource: "images/menu/ic_add_site.png"
            title: qsTr("Add Website") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            function endsWith(str, suffix) {
                return str.indexOf(suffix, str.length - suffix.length) !== -1;
            }
            
            onTriggered: {
                console.log("UserEvent: NewSite");
                var uri = persist.showBlockingPrompt( qsTr("Enter url"), qsTr("Please enter the website address for this individual:"), "http://", qsTr("Enter url (ie: http://mtws.com)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Url ).trim().toLowerCase();
                
                if (uri.length > 0)
                {
                    if ( endsWith(uri, "/") ) {
                        uri = uri.substring(0, uri.length-1);
                    }
                    
                    if ( uri.indexOf("http://") == -1 && uri.indexOf("https://") == -1 ) {
                        uri = "http://"+uri;
                    }
                    
                    uri = uri.replace("//www.", "//");
                    
                    if ( textUtils.isUrl(uri) ) {
                        tafsirHelper.addWebsite(createRijaal, individualId, uri);
                    } else {
                        persist.showToast( qsTr("Invalid URL entered!"), "images/menu/ic_remove_site.png" );
                        console.log("FailedRegex", uri);
                    }
                }
            }
        },
        
        ActionItem
        {
            id: addEmail
            imageSource: "images/menu/ic_add_email.png"
            title: qsTr("Add Email") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: NewEmail");
                var email = persist.showBlockingPrompt( qsTr("Enter email"), qsTr("Please enter the email address for this individual:"), "", qsTr("Enter email (ie: abc@hotmail.com)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Email ).trim().toLowerCase();

                if (email.length > 0)
                {
                    if ( textUtils.isEmail(email) ) {
                        tafsirHelper.addWebsite(createRijaal, individualId, email);
                    } else {
                        persist.showToast( qsTr("Invalid email entered!"), "images/menu/ic_remove_email.png" );
                        console.log("FailedRegex", email);
                    }
                }
            }
        },
        
        ActionItem
        {
            id: addPhone
            imageSource: "images/menu/ic_add_phone.png"
            title: qsTr("Add Phone") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: NewPhone");
                var phone = persist.showBlockingPrompt( qsTr("Enter phone number"), qsTr("Please enter the phone number for this individual:"), "", qsTr("Enter phone (ie: +44133441623)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Phone ).trim();
                
                if (phone.length > 0)
                {
                    if ( textUtils.isPhoneNumber(phone) ) {
                        tafsirHelper.addWebsite(createRijaal, individualId, phone);
                    } else {
                        persist.showToast( qsTr("Invalid email entered!"), "images/menu/ic_remove_phone.png" );
                        console.log("FailedRegex", phone);
                    }
                }
            }
        }
    ]
    
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
                location.text = data.location.toString();
            }
            
            if  (data.city) {
                location.hintText = data.city;
            }
        } else if (id == QueryId.FetchAllWebsites) {
            sites.count = results.length;
            results = offloader.fillType(results, id);
            adm.clear();
            adm.append(results);
        } else if (id == QueryId.AddWebsite) {
            persist.showToast( qsTr("Website added!"), "asset:///images/menu/ic_add_site.png" );
            tafsirHelper.fetchAllWebsites(createRijaal, individualId);
        } else if (id == QueryId.RemoveWebsite) {
            persist.showToast( qsTr("Entry removed!"), "asset:///images/menu/ic_remove_site.png" );
            tafsirHelper.fetchAllWebsites(createRijaal, individualId);
        }
    }
    
    titleBar: TitleBar
    {
        title: location.focused ? location.hintText : individualId ? qsTr("Edit Individual") + Retranslate.onLanguageChanged : qsTr("New Individual") + Retranslate.onLanguageChanged
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
                            var x = tafsirHelper.parseName(n);
                            
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
                location.validator.validate();
                
                if (name.validator.valid && location.validator.valid) {
                    createIndividual(individualId, prefix.text.trim(), name.text.trim(), kunya.text.trim(), displayName.text.trim(), hidden.checked, parseInt( birth.text.trim() ), parseInt( death.text.trim() ), female.checked, location.text.trim(), level.selectedValue );
                } else if (!location.validator.valid) {
                    persist.showToast( qsTr("Invalid location specified!"), "images/toast/incomplete_field.png" );
                } else {
                    persist.showToast( qsTr("Invalid name!"), "images/toast/incomplete_field.png" );
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
                
                SegmentedControl
                {
                    id: level
                    horizontalAlignment: HorizontalAlignment.Fill
                    topMargin: 0; bottomMargin: 0
                    
                    Option {
                        imageSource: "images/list/ic_individual.png"
                        text: qsTr("None") + Retranslate.onLanguageChanged
                        value: undefined
                    }
                    
                    Option {
                        imageSource: "images/list/ic_companion.png"
                        text: qsTr("Companion") + Retranslate.onLanguageChanged
                        value: 1
                    }
                    
                    Option {
                        imageSource: "images/list/ic_parent.png"
                        text: qsTr("Tabi'ee") + Retranslate.onLanguageChanged
                        value: 2
                    }
                    
                    Option {
                        imageSource: "images/list/ic_sibling.png"
                        text: qsTr("Tabi' Tabi'een") + Retranslate.onLanguageChanged
                        value: 3
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
                                    prefix.text = textUtils.toTitleCase( persist.getClipboardText() );
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
                                    kunya.text = textUtils.toTitleCase( persist.getClipboardText() );
                                }
                            }
                        ]
                    }
                }
                
                Header {
                    topMargin: 10
                    title: location.focused ? location.hintText : qsTr("Historical Information") + Retranslate.onLanguageChanged
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
                        
                        gestureHandlers: [
                            DoubleTapHandler {
                                onDoubleTapped: {
                                    console.log("UserEvent: DeathDoubleTapped");
                                    death.text = persist.getClipboardText();
                                }
                            }
                        ]
                    }
                    
                    TextField
                    {
                        id: location
                        hintText: qsTr("City of birth...") + Retranslate.onLanguageChanged
                        horizontalAlignment: HorizontalAlignment.Fill
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                        input.submitKey: SubmitKey.Search
                        input.keyLayout: KeyLayout.Text
                        inputMode: TextFieldInputMode.Text
                        
                        input.onSubmitted: {
                            console.log("UserEvent: CityOfBirthSubmit");
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
                                        createLocationPicker();
                                        var tokens = trimmed.split(",");
                                        app.geoLookup( parseCoordinate(tokens[0]), parseCoordinate(tokens[1]) );
                                    } else if ( trimmed.match("-{0,1}\\d.+,\\s+-{0,1}\\d.+") ) {
                                        createLocationPicker();
                                        var tokens = trimmed.split(",");
                                        app.geoLookup( parseFloat( tokens[0].trim() ), parseFloat( tokens[1].trim() ) );
                                    } else if ( trimmed.match("\\d+$") ) {
                                        valid = true;
                                    } else {
                                        createLocationPicker();
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
                                    navigationPane.pop();
                                }
                                
                                onDoubleTapped: {
                                    console.log("UserEvent: LocationFieldDoubleTapped");
                                    var p = createLocationPicker();
                                    p.performSearch();
                                }
                            }
                        ]
                    }
                }
            }
        }
        
        Header {
            id: sites
            property int count: 0
            title: qsTr("Websites, & Contact Information") + Retranslate.onLanguageChanged
            visible: count > 0
            subtitle: count
        }
        
        ListView
        {
            visible: sites.visible
            scrollRole: ScrollRole.Main
            
            onCreationCompleted: {
                maxHeight = deviceUtils.pixelSize/3;
            }
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function itemType(data, indexPath) {
                return data.type;
            }
            
            function deleteSite(ListItemData)
            {
                tafsirHelper.removeWebsite(createRijaal, ListItemData.id);
                
                if (ListItemData.type == "email") {
                    persist.showToast( qsTr("Email address removed!"), "images/menu/ic_remove_email.png" );
                } else if (ListItemData.type == "phone") {
                    persist.showToast( qsTr("Phone number removed!"), "images/menu/ic_remove_phone.png" );
                } else if (ListItemData.type == "uri") {
                    persist.showToast( qsTr("Website address removed!"), "images/menu/ic_remove_site.png" );
                }
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "website"
                    
                    StandardListItem
                    {
                        id: sli
                        imageSource: ListItemData.imageSource
                        title: ListItemData.uri
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_site.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteSite");
                                        sli.ListItem.view.deleteSite(ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "email"
                    
                    StandardListItem
                    {
                        id: sliEmail
                        imageSource: "images/list/ic_email.png"
                        title: ListItemData.uri
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sliEmail.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_email.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteSite");
                                        sliEmail.ListItem.view.deleteSite(ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "phone"
                    
                    StandardListItem
                    {
                        id: sliPhone
                        imageSource: "images/list/ic_phone.png"
                        title: ListItemData.uri
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sliPhone.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_phone.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: DeleteSite");
                                        sliPhone.ListItem.view.deleteSite(ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
        }
    }
    
    function createLocationPicker()
    {
        definition.source = "LocationPickerPage.qml";
        var p = definition.createObject();
        p.picked.connect(dth.onPicked);
        
        navigationPane.push(p);
        
        return p;
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