import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: createPage
    property variant quoteId
    property alias author: authorField.pickedId
    property alias body: bodyField.text
    property alias reference: referenceField.text
    property alias uri: uriField.text
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onQuoteIdChanged: {
        if (quoteId) {
            tafsirHelper.fetchQuote(createPage, quoteId);
        }
    }
    
    function cleanUp() {}
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchQuote && results.length > 0)
        {
            var data = results[0];
            
            authorField.pickedId = data.author_id;
            translatorField.pickedId = data.translator_id;
            bodyField.text = data.body;
            referenceField.text = data.reference;
            
            if (data.suite_id) {
                suiteId.pickedId = data.suite_id;
            }
            
            if (data.uri) {
                uriField.text = data.uri;
            }
        }
    }
    
    function toSentenceCase(inputString)
    {
        inputString = "." + inputString;
        var result = "";
        if (inputString.length == 0) {
            return result;
        }
        
        var terminalCharacterEncountered = false;
        var terminalCharacters = [".", "?", "!"];
        var n = inputString.length;

        for (var i = 0; i < n; i++)
        {
            var currentChar = inputString.charAt(i);

            if (terminalCharacterEncountered)
            {
                if (currentChar == ' ') {
                    result = result + currentChar;
                } else {
                    result = result + currentChar.toUpperCase();
                    terminalCharacterEncountered = false;
                }
            } else {
                var currentToLower = currentChar.toLowerCase();
                var prev = i > 0 ? inputString.charAt(i-1) : '';
                var next = i < n-1 ? inputString.charAt(i+1) : '';
                
                if (currentToLower == 'i' && prev == ' ' && next == ' ') {
                    currentToLower = currentChar.toUpperCase();
                }

                result = result + currentToLower;
            }

            for (var j = 0; j < terminalCharacters.length; j++)
            {
                if (currentChar == terminalCharacters[j])
                {
                    terminalCharacterEncountered = true;
                    break;
                }
            }
        }

        result = result.substring(1, result.length);
        return result;
    }
    
    actions: [
        ActionItem
        {
            enabled: bodyField.text.length > 0
            imageSource: "images/tabs/ic_utils.png"
            title: qsTr("Fix Body") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: FixQuoteBody");
                bodyField.text = toSentenceCase(bodyField.text);
            }
        },
        
        ActionItem
        {
            imageSource: "images/list/ic_geo_search.png"
            title: qsTr("Find Source") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: FindSource");
                persist.openUri( uriField.text.length == 0 ? "https://www.google.ca/search?q=\"%1\"&ie=UTF-8".arg( encodeURIComponent(body) ) : uriField.text );
            }
        }
    ]
    
    titleBar: TitleBar
    {
        title: quoteId > 0 ? qsTr("Edit Quote") + Retranslate.onLanguageChanged : qsTr("New Quote") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/dropdown/save_quote.png"
            enabled: true
            
            onTriggered: {
                console.log("UserEvent: CreateQuoteSaveTriggered");
                
                if ( authorField.pickedId && bodyField.text.trim().length > 3 && ( suiteId.text.trim().length > 0 || referenceField.text.trim().length > 3) )
                {
                    var data = {author: authorField.pickedId, authorName: authorField.value.trim(),
                                translator: translatorField.pickedId, translatorName: translatorField.value.trim(),
                                body: bodyField.text.trim(), reference: referenceField.text.trim(), url: uriField.text.trim(),
                                suite_id: suiteId.pickedId, from_page: fromPage.text.trim(), to_page: toPage.text.trim(),
                                volume_number: volNumber.text.trim(), book_number: bookNumber.text.trim(),
                                indexed_number: indexNumber.text.trim()};
                    createQuote( quoteId, authorField.pickedId, translatorField.pickedId, bodyField.text.trim(), referenceField.text.trim(), suiteId.pickedId, uriField.text.trim() );
                }
            }
        }
    }
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            topPadding: 10
            
            AuthorControl
            {
                id: authorField
                label: qsTr("Author") + Retranslate.onLanguageChanged
                table: "quotes"
            }
            
            AuthorControl
            {
                id: translatorField
                field: "translator"
                label: qsTr("Translator") + Retranslate.onLanguageChanged
                table: "quotes"
            }
            
            TextArea {
                id: bodyField
                hintText: qsTr("Body...") + Retranslate.onLanguageChanged
                minHeight: 150
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: QuoteBodyDoubleTapped"); 
                            bodyField.text = global.getCapitalizedClipboard();
                        }
                    }
                ]
            }

            TextArea
            {
                id: referenceField
                hintText: qsTr("Reference...") + Retranslate.onLanguageChanged
                minHeight: 150
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveText
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: QuoteRefDoubleTapped");
                            referenceField.text = persist.getClipboardText();
                        }
                    }
                ]
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                TextField {
                    id: fromPage
                    hintText: qsTr("From Page") + Retranslate.onLanguageChanged
                    clearButtonVisible: false
                    input.flags: TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoCapitalizationOff
                    inputMode: TextFieldInputMode.NumbersAndPunctuation
                }
                
                TextField {
                    id: toPage
                    hintText: qsTr("To Page") + Retranslate.onLanguageChanged
                    clearButtonVisible: false
                    input.flags: TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoCapitalizationOff
                    inputMode: TextFieldInputMode.NumbersAndPunctuation
                }
                
                TextField {
                    id: volNumber
                    hintText: qsTr("Volume") + Retranslate.onLanguageChanged
                    clearButtonVisible: false
                    input.flags: TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoCapitalizationOff
                    inputMode: TextFieldInputMode.NumbersAndPunctuation
                }
                
                TextField {
                    id: bookNumber
                    hintText: qsTr("Book #") + Retranslate.onLanguageChanged
                    clearButtonVisible: false
                    content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                    input.flags: TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoCapitalizationOff
                    inputMode: TextFieldInputMode.NumbersAndPunctuation
                }
                
                TextField {
                    id: indexNumber
                    hintText: qsTr("Index #") + Retranslate.onLanguageChanged
                    clearButtonVisible: false
                    input.flags: TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoCapitalizationOff
                    inputMode: TextFieldInputMode.NumbersAndPunctuation
                }
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                Button
                {
                    id: suiteId
                    property variant pickedId
                    property string label: qsTr("Suite ID...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    leftMargin: 0; rightMargin: 0

                    function reset()
                    {
                        text = label;
                        resetImageSource();
                    }

                    onPickedIdChanged: {
                        if (pickedId) {
                            tafsirHelper.fetchTafsirMetadata(suiteId, pickedId);
                        } else {
                            reset();
                        }
                    }

                    onCreationCompleted: {
                        reset();
                    }
                    
                    function onDataLoaded(id, data)
                    {
                        if (id == QueryId.FetchTafsirHeader)
                        {
                            if (data.length > 0) {
                                imageSource = "images/list/ic_book.png"
                                text = data[0].displayName ? data[0].displayName : data[0].title;
                                
                                if (!authorField.pickedId) {
                                    authorField.pickedId = data[0].author;
                                }
                            } else {
                                reset();
                            }
                        }
                    }
                    
                    function onPicked(data)
                    {
                        pickedId = data[0].id;
                        Qt.popToRoot(createPage);
                    }
                    
                    onClicked: {
                        console.log("UserEvent: QuoteSuiteDoubleTapped");

                        var p = Qt.launch("TafsirPickerPage.qml");
                        p.tafsirPicked.connect(onPicked);
                        p.autoFocus = true;
                        p.reload();
                    }
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 0.95
                    }
                }
                
                Button
                {
                    imageSource: "images/dropdown/cancel.png"
                    leftMargin: 0; rightMargin: 0
                    horizontalAlignment: HorizontalAlignment.Right
                    
                    onClicked: {
                        console.log("UserEvent: CancelSuite");
                        suiteId.pickedId = undefined;
                    }
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 0.05
                    }
                }
            }
            
            TextArea
            {
                id: uriField
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                hintText: qsTr("URL (for reference purposes only)") + Retranslate.onLanguageChanged
                
                gestureHandlers: [
                    DoubleTapHandler
                    {
                        onDoubleTapped: {
                            console.log("UserEvent: QuoteUriDoubleTapped");
                            var value = global.stripSlashFromClipboard();
                            uriField.text = value;
                            
                            if (!translatorField.pickedId)
                            {
                                var host = offloader.extractHost(value);
                                
                                if (host.length > 0) {
                                    translatorField.where = "uri LIKE '%%1%'".arg(host);
                                }
                            }
                        }
                    }
                ]
            }
        }
    }
}