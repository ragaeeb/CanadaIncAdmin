import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: createPage
    property variant suiteId
    signal createTafsir(variant id, variant author, variant translator, variant explainer, string title, string description, string reference)
    signal deleteTafsir(variant id)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function cleanUp() {}
    
    onSuiteIdChanged: {
        if (suiteId) {
            tafsirHelper.fetchTafsirMetadata(createPage, suiteId);
        }
    }
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchTafsirHeader && results.length > 0)
        {
            var data = results[0];
            
            if (data.author) {
                authorField.pickedId = data.author;
            }
            
            if (data.translator) {
                translatorField.pickedId = data.translator;
            }
            
            if (data.explainer) {
                explainerField.pickedId = data.explainer;
            }

            titleField.text = data.title;
            descriptionField.text = data.description;
            referenceField.text = data.reference;
        }
    }
    
    titleBar: TitleBar
    {
        title: suiteId > 0 ? qsTr("Edit Tafsir") + Retranslate.onLanguageChanged : qsTr("New Tafsir") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/dropdown/ic_accept_new_suite.png"
            enabled: true
            
            onTriggered: {
                console.log("UserEvent: CreateTafsirSaveTriggered");
                titleField.validator.validate();
                
                if (titleField.validator.valid) {
                    createTafsir( suiteId, authorField.pickedId, translatorField.pickedId, explainerField.pickedId, titleField.text.trim(), descriptionField.text.trim(), referenceField.text.trim() );
                }
            }
        }
    }
    
    actions: [
        DeleteActionItem
        {
            enabled: suiteId > 0
            imageSource: "images/menu/ic_remove_suite.png"
            
            onTriggered: {
                console.log("UserEvent: DeleteSuite");
                
                var yes = persist.showBlockingDialog( qsTr("Confirmation"), qsTr("Are you sure you want to delete this suite?") );
                
                if (yes) {
                    deleteTafsir(suiteId);
                }
            }
        }
    ]
    
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
                label: qsTr("Author name") + Retranslate.onLanguageChanged
            }
            
            AuthorControl
            {
                id: translatorField
                field: "translator"
                label: qsTr("Translator") + Retranslate.onLanguageChanged
            }
            
            AuthorControl
            {
                id: explainerField
                field: "explainer"
                label: qsTr("Explainer") + Retranslate.onLanguageChanged
            }
            
            TextField
            {
                id: titleField
                hintText: qsTr("Title") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                
                validator: Validator
                {
                    errorMessage: qsTr("Title cannot be empty...") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: {
                        valid = titleField.text.trim().length > 0;
                    }
                }
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: TafsirTitleDoubleTapped");
                            titleField.text = global.optimizeAndClean( global.getCapitalizedClipboard() );
                        }
                    }
                ]
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
                            console.log("UserEvent: TafsirDescDoubleTapped");
                            descriptionField.text = persist.getClipboardText();
                        }
                    }
                ]
            }

            TextArea
            {
                id: referenceField
                hintText: qsTr("Reference...") + Retranslate.onLanguageChanged
                minHeight: ui.sdu(18.75)
                inputMode: TextAreaInputMode.Text
                content.flags: TextContentFlag.EmoticonsOff | TextContentFlag.ActiveText
                input.flags: TextInputFlag.AutoCapitalization | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
                
                gestureHandlers: [
                    DoubleTapHandler
                    {
                        onDoubleTapped: {
                            console.log("UserEvent: TafsirRefDoubleTapped");
                            var value = persist.getClipboardText();
                            referenceField.text = value;

                            var host = offloader.extractHost(value);
                            
                            if (host.length > 0)
                            {
                                if (!translatorField.pickedId) {
                                    translatorField.where = "reference LIKE '%%1%'".arg(host);
                                }
                            }
                        }
                    }
                ]
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
            source: "IndividualPickerPage.qml"
        }
    ]
}