import bb.cascades 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: csp
    property variant suitePageId
    property bool focusable: false
    signal createSuitePage(variant id, string body, string header, string reference)
    
    function cleanUp() {
        Qt.navigationPane.pushTransitionEnded.disconnect(checkFocus);
    }
    
    function getIndicesOf(searchStr, str, caseSensitive)
    {
        var startIndex = 0, searchStrLen = searchStr.length;
        var index, indices = [];
        
        if (!caseSensitive) {
            str = str.toLowerCase();
            searchStr = searchStr.toLowerCase();
        }
        
        while ((index = str.indexOf(searchStr, startIndex)) > -1) {
            indices.push(index);
            startIndex = index + searchStrLen;
        }
        
        return indices;
    }
    
    function checkFocus()
    {
        Qt.navigationPane.pushTransitionEnded.disconnect(checkFocus);
        
        if (focusable) {
            bodyField.editable = true;
        }
    }
    
    onCreationCompleted: {
        Qt.navigationPane.pushTransitionEnded.connect(checkFocus);
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchTafsirContent && data.length > 0)
        {
            var d = data[0];
            
            if (d.heading) {
                heading.text = d.heading;
            }
            
            if (d.body) {
                bodyField.text = d.body;
            }
            
            if (d.reference) {
                referenceField.text = d.reference;
            }
        }
    }
    
    onSuitePageIdChanged: {
        if (suitePageId) {
            tafsirHelper.fetchTafsirContent(csp, suitePageId);
        }
    }
    
    actions: [
        ActionItem
        {
            id: optimize
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_settings.png"
            title: qsTr("Optimize Text") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: OptimizeContent");
                bodyField.text = bodyField.text.replace(/\n/g, " ");
            }
        },
        
        ActionItem
        {
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_settings.png"
            title: qsTr("Open Links") + Retranslate.onLanguageChanged
            enabled: suitePageId != undefined
            
            onTriggered: {
                console.log("UserEvent: OpenLinks");
                
                var page = Qt.launch("SuitePageLinks.qml");
                page.suitePageId = suitePageId;
            }
        },
        
        ActionItem
        {
            id: findAction
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_search.png"
            title: qsTr("Find") + Retranslate.onLanguageChanged
            property variant indices: []
            property string query
            
            onTriggered: {
                console.log("UserEvent: SearchSuiteText");
                focusable = true;

                if (indices.length == 0)
                {
                    query = persist.showBlockingPrompt( qsTr("Enter query"), qsTr("Please enter search query:"), "", qsTr("Enter any non-empty value"), 60, false ).trim();
                    
                    if (query.length > 0) {
                        indices = getIndicesOf(query, bodyField.text, false);
                    }
                }
                
                if (indices.length > 0)
                {
                    var allIndices = indices;
                    var index = allIndices.pop();
                    indices = allIndices;
                    
                    bodyField.editor.setSelection(index, index+query.length);
                    bodyField.requestFocus();
                }
            }
        }
    ]
    
    titleBar: TitleBar
    {
        title: !suitePageId ? qsTr("New Page") + Retranslate.onLanguageChanged : qsTr("Edit Page") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            id: saveAction
            imageSource: "images/dropdown/suite_changes_accept.png"
            title: qsTr("Save") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: SuitePageSave");
                
                var body = bodyField.text.trim();
                var header = heading.text.trim();
                var reference = referenceField.text.trim();
                
                createSuitePage(suitePageId, body, header, reference);
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        TextField
        {
            id: heading
            horizontalAlignment: HorizontalAlignment.Fill
            hintText: qsTr("Heading...") + Retranslate.onLanguageChanged
            backgroundVisible: false
            enabled: bodyField.editable
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff
            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
            
            gestureHandlers: [
                DoubleTapHandler {
                    onDoubleTapped: {
                        console.log("UserEvent: TafsirHeadingDoubleTapped");
                        heading.text = global.optimizeAndClean( global.getCapitalizedClipboard() );
                    }
                }
            ]
        }
        
        TextArea
        {
            id: bodyField
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            backgroundVisible: false
            content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
            hintText: qsTr("Enter tafsir body here...") + Retranslate.onLanguageChanged
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff
            topPadding: 0; topMargin: 0
            editable: false
            
            onEditableChanged: {
                if (editable) {
                    requestFocus();
                }
            }
            
            onTextChanging: {
                saveAction.enabled = text.trim().length > 10;
            }
            
            gestureHandlers: [
                DoubleTapHandler {
                    onDoubleTapped: {
                        console.log("UserEvent: TafsirBodyDoubleTapped");
                        
                        if (bodyField.editable)
                        {
                            var body = invokeHelper.optimize( persist.getClipboardText() );
                            body = body.replace(/ÑÍãå Çááå/g, "رحمه الله");
                            body = body.replace(/ÍÝÙå Çááå/g, "حفظه الله");
                            body = body.replace(/æ ÇáÍãÏ ááå/g, "ماشاء الله");
                            body = body.replace(/Åä ÔÇÁ Çááå/g, " إن شاء الله‎");
                            body = body.replace(/ò/g, "");
                            
                            bodyField.text = body;
                        }
                    }
                },
                
                TapHandler {
                    onTapped: {
                        console.log("UserEvent: TafsirBodyTapped");
                        
                        if (!bodyField.editable) {
                            bodyField.editable = !bodyField.editable;
                        }
                    }
                }
            ]
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
        }
        
        TextArea
        {
            id: referenceField
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            backgroundVisible: false
            content.flags: TextContentFlag.ActiveText | TextContentFlag.EmoticonsOff
            hintText: qsTr("Enter reference here...") + Retranslate.onLanguageChanged
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.AutoCorrectionOff | TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff
            topPadding: 0; topMargin: 0
            editable: bodyField.editable
            
            gestureHandlers: [
                DoubleTapHandler {
                    onDoubleTapped: {
                        console.log("UserEvent: TafsirReferenceDoubleTapped");
                        referenceField.text = global.stripSlashFromClipboard();
                    }
                }
            ]
        }
    }
}