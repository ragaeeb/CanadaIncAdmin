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
    signal createQuote(variant id, string author, string body, string reference, variant suiteId, string uri)
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
                    createQuote( quoteId, authorField.pickedId, bodyField.text.trim(), referenceField.text.trim(), suiteId.text.trim(), uriField.text.trim() );
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
            
            IndividualTextField
            {
                id: authorField
                text: qsTr("Author name") + Retranslate.onLanguageChanged
                table: "quotes"
            }
            
            TextArea {
                id: bodyField
                hintText: qsTr("Body...") + Retranslate.onLanguageChanged
                minHeight: 150
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                
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
            
            TextField
            {
                id: suiteId
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                hintText: qsTr("Suite ID...") + Retranslate.onLanguageChanged
                
                gestureHandlers: [
                    DoubleTapHandler
                    {
                        function onPicked(data)
                        {
                            suiteId.text = data[0].id.toString();
                            navigationPane.pop();
                        }
                        
                        onDoubleTapped: {
                            console.log("UserEvent: QuoteSuiteDoubleTapped");
                            definition.source = "TafsirPickerPage.qml";
                            
                            var p = definition.createObject();
                            p.tafsirPicked.connect(onPicked);
                            p.autoFocus = true;
                            p.reload();
                            
                            navigationPane.push(p);
                        }
                    }
                ]
            }
            
            TextArea
            {
                id: uriField
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveTextOff
                input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                input.submitKey: SubmitKey.Submit
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
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}