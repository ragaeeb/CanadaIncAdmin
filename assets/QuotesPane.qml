import bb.cascades 1.3
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    property alias searchField: tftk.textField
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function reload()
    {
        busy.delegateActive = true;
        tafsirHelper.fetchAllQuotes(listView, 0, 0, 0, persist.getValueFor("optimizeQueries") == 1 ? 200 : 999999);
    }
    
    function clearAndReload()
    {
        adm.clear();
        reload();
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(quotePickerPage, listView, true);
        reload();
        app.textualChange.connect(clearAndReload);
    }
    
    Page
    {
        id: quotePickerPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        actions: [
            ActionItem
            {
                id: addAction
                imageSource: "images/menu/ic_add_quote.png"
                title: qsTr("Add") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
                
                function onCreate(id, author, translator, body, reference, suiteId, uri)
                {
                    var x = tafsirHelper.addQuote(author, translator, body, reference, suiteId, uri);
                    tafsirHelper.fetchAllQuotes(listView, x.id);
                    
                    persist.showToast( qsTr("Quote added!"), "images/menu/ic_add_quote.png" );
                    
                    Qt.popToRoot(quotePickerPage);
                }
                
                onTriggered: {
                    var page = Qt.launch("CreateQuotePage.qml")
                    page.createQuote.connect(onCreate);
                }
            },
            
            ActionItem
            {
                imageSource: "images/menu/ic_find_duplicate_quotes.png"
                title: qsTr("Find Duplicates") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: FindDuplicateQuotes");
                    busy.delegateActive = true;
                    tafsirHelper.findDuplicateQuotes(listView, searchColumn.selectedValue);
                }
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.Search
                    }
                ]
            },
            
            DeleteActionItem
            {
                id: clearAll
                imageSource: "images/menu/ic_reset_search.png"
                title: qsTr("Clear") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    tftk.textField.resetText();
                    tftk.textField.requestFocus();
                }
            }
        ]
        
        titleBar: TitleBar
        {
            kind: TitleBarKind.TextField
            kindProperties: TextFieldTitleBarKindProperties
            {
                id: tftk
                textField.hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
                textField.input.submitKey: SubmitKey.Search
                textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                textField.input.onSubmitted: {
                    var query = searchField.text.trim();
                    
                    if (query.length == 0)
                    {
                        adm.clear();
                        reload();
                    } else {
                        busy.delegateActive = true;
                        tafsirHelper.searchQuote(listView, searchColumn.selectedValue, query);
                    }
                }
                
                onCreationCompleted: {
                    textField.input["keyLayout"] = 7;
                }
                
                textField.gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: DoubleTappedQuoteSearch");
                            tftk.textField.text = persist.getClipboardText();
                        }
                    }
                ]
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                SegmentedControl
                {
                    id: searchColumn
                    horizontalAlignment: HorizontalAlignment.Fill
                    bottomMargin: 0
                    
                    Option {
                        description: qsTr("Search author field") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_quotes_author.png"
                        text: qsTr("Author") + Retranslate.onLanguageChanged
                        value: "author"
                    }
                    
                    Option {
                        description: qsTr("Search quote text") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_quote_body.png"
                        text: qsTr("Body") + Retranslate.onLanguageChanged
                        value: "body"
                        selected: true
                    }
                    
                    Option {
                        description: qsTr("Search reference field") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_quote_reference.png"
                        text: qsTr("Reference") + Retranslate.onLanguageChanged
                        value: "quotes.reference"
                    }
                    
                    Option {
                        description: qsTr("Search URI field") + Retranslate.onLanguageChanged
                        imageSource: "images/dropdown/search_uri.png"
                        text: qsTr("URI") + Retranslate.onLanguageChanged
                        value: "uri"
                    }
                }
                
                ListView
                {
                    id: listView
                    property variant editIndexPath
                    scrollRole: ScrollRole.Main
                    
                    dataModel: ArrayDataModel {
                        id: adm
                    }
                    
                    function onDataLoaded(id, data)
                    {
                        if (id == QueryId.FetchAllQuotes && data.length > 0)
                        {
                            adm.insert(0, data);
                            navigationPane.parent.unreadContentCount = adm.size();
                            
                            listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                        } else if (id == QueryId.RemoveQuote) {
                            persist.showToast( qsTr("Quote removed!"), "images/menu/ic_delete_quote.png" );
                        } else if (id == QueryId.EditQuote) {
                            persist.showToast( qsTr("Quote updated!"), "images/menu/ic_edit_quote.png" );
                        } else if (id == QueryId.TranslateQuote) {
                            persist.showToast( qsTr("Quote translated!"), "images/menu/ic_preview.png" );
                            persist.saveValueFor("translation", "arabic");
                        } else if (id == QueryId.SearchQuote || id == QueryId.FindDuplicates) {
                            adm.clear();
                            adm.append(data);
                        }
                        
                        updateState();
                    }
                    
                    function onEdit(id, author, translator, body, reference, suiteId, uri)
                    {
                        busy.delegateActive = true;
                        tafsirHelper.editQuote(listView, id, author, translator, body, reference, suiteId, uri);
                        
                        var current = dataModel.data(editIndexPath);
                        current["body"] = body;
                        current["reference"] = reference;
                        current["suite_id"] = suiteId;
                        current["uri"] = uri;

                        dataModel.replace(editIndexPath[0], current);

                        Qt.popToRoot(quotePickerPage);
                    }
                    
                    function openQuote(ListItemData)
                    {
                        var page = Qt.launch("CreateQuotePage.qml")
                        page.quoteId = ListItemData.id;
                        
                        return page;
                    }
                    
                    function duplicateQuote(ListItemData)
                    {
                        var page = openQuote(ListItemData);
                        page.createQuote.connect(addAction.onCreate);
                        page.titleBar.title = qsTr("New Quote");
                    }
                    
                    function translateQuote(indexPath, ListItemData)
                    {
                        //editItem(indexPath, ListItemData);
                        tafsirHelper.translateQuote(listView, ListItemData.id);
                    }
                    
                    function editItem(indexPath, ListItemData)
                    {
                        editIndexPath = indexPath;
                        var page = openQuote(ListItemData);
                        page.createQuote.connect(onEdit);
                    }
                    
                    function removeItem(ListItemData)
                    {
                        busy.delegateActive = true;
                        tafsirHelper.removeQuote(listView, ListItemData.id);
                    }
                    
                    listItemComponents: [
                        ListItemComponent
                        {
                            StandardListItem
                            {
                                id: rootItem
                                description: ListItemData.body
                                imageSource: "images/list/ic_quote.png"
                                title: ListItemData.author
                                status: ListItemData.c ? ListItemData.c : undefined
                                
                                contextActions: [
                                    ActionSet
                                    {
                                        title: rootItem.title
                                        subtitle: rootItem.description
                                        
                                        ActionItem
                                        {
                                            imageSource: "images/common/ic_copy.png"
                                            title: qsTr("Copy") + Retranslate.onLanguageChanged
                                            
                                            onTriggered: {
                                                console.log("UserEvent: CopyQuote");
                                                
                                                var reference = ListItemData.reference;
                                                
                                                if (ListItemData.title) {
                                                    reference = ListItemData.title + " "+reference;
                                                }

                                                var body = "“%1” - %2 [%3]".arg(ListItemData.body).arg(ListItemData.author).arg( reference.trim() );
                                                
                                                if (ListItemData.translator) {
                                                    body += "\n\nTranslated by: %1".arg(ListItemData.translator);
                                                }
                                                
                                                persist.copyToClipboard(body);
                                            }
                                        }
                                        
                                        ActionItem
                                        {
                                            imageSource: "images/menu/ic_edit_quote.png"
                                            title: qsTr("Edit") + Retranslate.onLanguageChanged
                                            
                                            onTriggered: {
                                                console.log("UserEvent: EditQuote");
                                                rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                            }
                                        }
                                        
                                        ActionItem
                                        {
                                            imageSource: "images/menu/ic_translate_quote.png"
                                            title: qsTr("Translate") + Retranslate.onLanguageChanged
                                            
                                            onTriggered: {
                                                console.log("UserEvent: TranslateQuote");
                                                rootItem.ListItem.view.translateQuote(rootItem.ListItem.indexPath, ListItemData);
                                            }
                                        }
                                        
                                        DeleteActionItem
                                        {
                                            imageSource: "images/menu/ic_delete_quote.png"
                                            
                                            onTriggered: {
                                                console.log("UserEvent: DeleteQuoteTriggered");
                                                rootItem.ListItem.view.removeItem(ListItemData);
                                                rootItem.ListItem.view.dataModel.removeAt(rootItem.ListItem.indexPath[0]);
                                            }
                                        }
                                    }
                                ]
                            }
                        }
                    ]
                    
                    onTriggered: {
                        console.log("UserEvent: QuoteTriggered");
                        var d = dataModel.data(indexPath);
                        duplicateQuote(d);
                    }
                }
            }
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_quotes.png"
                labelText: qsTr("No quotes matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: NoQuotesTapped");
                    searchField.requestFocus();
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_quotes.png"
            }
        }
    }
    
    function updateState()
    {
        busy.delegateActive = false;
        listView.visible = !adm.isEmpty();
        noElements.delegateActive = !listView.visible;
    }
}