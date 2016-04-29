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
    property alias bufferText: buffer.text
    signal createQuote(variant id, variant author, variant translator, string body, string reference, variant suiteId, string uri)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onQuoteIdChanged: {
        if (quoteId) {
            tafsirHelper.fetchQuote(createPage, quoteId);
        }
    }
    
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
                suiteId.text = data.suite_id.toString();
            }
            
            if (data.uri) {
                uriField.text = data.uri;
            }
        }
    }
    
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
                
                if ( authorField.pickedId && bodyField.text.trim().length > 3 && ( suiteId.text.trim().length > 0 || referenceField.text.trim().length > 3) ) {
                    createQuote( quoteId, authorField.pickedId, translatorField.pickedId, bodyField.text.trim(), referenceField.text.trim(), suiteId.text.trim(), uriField.text.trim() );
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
            
            Button
            {
                id: suiteId
                property variant pickedId
                horizontalAlignment: HorizontalAlignment.Fill
                text: qsTr("Suite ID...") + Retranslate.onLanguageChanged
                
                onPickedIdChanged: {
                    if (pickedId) {
                        tafsirHelper.fetchTafsirMetadata(suiteId, pickedId);
                    }
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchTafsirHeader && data.length > 0)
                    {
                        imageSource = "images/list/ic_book.png"
                        text = data[0].title;
                    }
                }
                
                function onPicked(data)
                {
                    pickedId = data[0].id;
                    navigationPane.pop();
                }
                
                onClicked: {
                    console.log("UserEvent: QuoteSuiteDoubleTapped");
                    definition.source = "TafsirPickerPage.qml";
                    
                    var p = definition.createObject();
                    p.tafsirPicked.connect(onPicked);
                    p.autoFocus = true;
                    p.reload();
                    
                    navigationPane.push(p);
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
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: QuoteUriDoubleTapped");
                            uriField.text = persist.getClipboardText();
                        }
                    }
                ]
            }
            
            TextArea
            {
                id: buffer
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff
                hintText: qsTr("Buffer (not used)...") + Retranslate.onLanguageChanged
                backgroundVisible: false
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}