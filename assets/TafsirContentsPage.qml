import bb.cascades 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: tafsirContentsPage
    property variant suiteId
    property int tagId
    property variant searchData
    property alias title: tb.title
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onTagIdChanged: {
        if (tagId)
        {
            busy.delegateActive = true;
            salat.fetchPagesForTag(listView, tagId);
        }
    }
    
    onSuiteIdChanged: {
        if (suiteId)
        {
            busy.delegateActive = true;
            tafsirHelper.fetchAllQuotes(listView, 0, 0, suiteId);
            tafsirHelper.fetchAllTafsirForSuite(listView, suiteId);
            
            var marker = persist.getValueFor("suitePageMarker");
            
            if ( marker && (marker.suiteId == suiteId) ) {
                tafsirContentsPage.addAction(jumpToMarker);
            } else {
                tafsirContentsPage.removeAction(jumpToMarker);
            }
        }
    }
    
    function refresh()
    {
        busy.delegateActive = false;
        listView.visible = !adm.isEmpty();
        noElements.delegateActive = !listView.visible;
    }
    
    function cleanUp() {
        app.textualChange.disconnect(reload);
    }
    
    function reload()
    {
        adm.clear();
        suiteIdChanged();
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(tafsirContentsPage, listView, true);
        app.textualChange.connect(reload);
    }
    
    titleBar: TitleBar {
        id: tb
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    
    actions: [
        ActionItem
        {
            id: addAction
            imageSource: "images/menu/ic_add_suite_page.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            function onCreateSuitePage(id, body, header, reference)
            {
                var x = tafsirHelper.addSuitePage(suiteId, body, header, reference);
                adm.insert(0,x);
                
                persist.showToast( qsTr("Suite page added!"), "images/menu/ic_add_suite_page.png" );
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                
                Qt.popToRoot(tafsirContentsPage);
                refresh();
                
                listView.triggered([0]); // open it up so user can add links
            }
            
            onTriggered: {
                console.log("UserEvent: TafsirContentAddTriggered");

                var c = Qt.launch("CreateSuitePage.qml");
                c.createSuitePage.connect(onCreateSuitePage);
                c.focusable = true;
            }
        }
    ]
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ListView
        {
            id: listView
            scrollRole: ScrollRole.Main
            property variant editIndexPath
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchAllTafsirForSuite)
                {
                    adm.append(data);
                    
                    if ( adm.isEmpty() ) {
                        addAction.triggered();
                    }
                    
                    if (searchData)
                    {
                        var suitePageId = searchData.suitePageId;
                        var query = searchData.query;
                        
                        for (var i = data.length-1; i >= 0; i--)
                        {
                            if (data[i].id == suitePageId)
                            {
                                if (query) {
                                    decorator.decorateSearchResults(data, adm, [query], "body", i);
                                }
                                
                                listView.scrollToItem([i], ScrollAnimation.None);
                                break;
                            }
                        }
                    }    
                } else if (id == QueryId.MoveToSuite) {
                    persist.showToast( qsTr("Suite page moved!"), "images/menu/ic_merge.png" );
                    
                    if ( copyConfirm.rememberMeSelection() ) {
                        tafsirHelper.removeSuite(listView, suiteId);
                    }
                } else if (id == QueryId.RemoveSuitePage) {
                    persist.showToast( qsTr("Tafsir page removed!"), "images/menu/ic_delete_suite_page.png" );
                } else if (id == QueryId.EditSuitePage) {
                    persist.showToast( qsTr("Tafsir page updated!"), "images/menu/ic_edit_suite_page.png" );
                    Qt.popToRoot(tafsirContentsPage);
                } else if (id == QueryId.TranslateSuitePage) {
                    persist.showToast( qsTr("Suite page ported!"), "images/menu/ic_translate.png" );
                    persist.saveValueFor("translation", "arabic");
                } else if (id == QueryId.FetchAllQuotes) {
                    adm.append(data);
                } else if (id == QueryId.RemoveSuite) {
                    Qt.navigationPane.pop();
                } else if (id == QueryId.FetchPagesForTag) {
                    adm.append(data);
                }
                
                refresh();
            }
            
            function removeItem(ListItemData)
            {
                tafsirHelper.removeSuitePage(listView, ListItemData.id);
                busy.delegateActive = true;
            }
            
            function onEditSuitePage(id, body, header, reference)
            {
                var x = dataModel.data(editIndexPath);
                x["body"] = body;
                x["heading"] = header;
                x["reference"] = reference;
                adm.replace(editIndexPath[0], x);
                
                tafsirHelper.editSuitePage(listView, id, body, header, reference);
            }
            
            function editItem(indexPath, ListItemData)
            {
                editIndexPath = indexPath;
                var c = Qt.launch("CreateSuitePage.qml");
                c.createSuitePage.connect(onEditSuitePage);
                
                c.suitePageId = ListItemData.id;
                c.focusable = true;
            }
            
            function onActualPicked(destination)
            {
                copyConfirm.destinationId = destination[0].id;
                Qt.popToRoot(tafsirContentsPage);
                
                copyConfirm.show();
            }
            
            function moveSuitePage(indexPath, ListItemData)
            {
                editIndexPath = indexPath;
                var ipp = Qt.launch("TafsirPickerPage.qml");
                ipp.autoFocus = true;
                ipp.exclusions = [suiteId];
                ipp.tafsirPicked.connect(onActualPicked);
            }
            
            function setSuitePageMarker(ListItem)
            {
                persist.saveValueFor("suitePageMarker", {'suiteId': suiteId, 'indexPath': ListItem.indexPath[0]});
                persist.showToast( qsTr("Market set"), "images/menu/ic_set_marker.png" );
            }
            
            function translateSuitePage(indexPath, ListItemData)
            {
                editItem(indexPath, ListItemData);
                tafsirHelper.translateSuitePage(listView, ListItemData.id);
            }
            
            function quiz(indexPath, ListItemData)
            {
                var page = Qt.launch("SuitePageQuestionsPage.qml");
                page.suitePageId = ListItemData.id;
            }
            
            function onEditQuote(id, author, translator, body, reference, suiteId, uri)
            {
                tafsirHelper.editQuote(listView, id, author, translator, body, reference, suiteId, uri);
                Qt.popToRoot(tafsirContentsPage);
            }
            
            onTriggered: {
                console.log("UserEvent: TafsirContentTriggered");
                
                var d = dataModel.data(indexPath);
                var type = itemType(d, indexPath);
                
                if (type == "page") {
                    var page = Qt.launch("SuitePageLinks.qml");
                    page.suitePageId = d.id;
                } else if (type == "quote") {
                    editIndexPath = indexPath;
                    var page = Qt.launch("CreateQuotePage.qml");
                    page.createQuote.connect(onEditQuote);
                    page.quoteId = d.id;
                }
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "page"
                    
                    Container
                    {
                        id: rootItem
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        Header {
                            id: header
                            title: ListItemData.heading && ListItemData.heading.length > 0 ? ListItemData.heading : ListItemData.id
                        }
                        
                        Label
                        {
                            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            multiline: true
                            text: ListItemData.body
                        }
                        
                        Label {
                            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                            horizontalAlignment: HorizontalAlignment.Fill
                            multiline: true
                            text: ListItemData.reference
                            topMargin: 20
                            visible: text.length > 0
                        }
                        
                        contextActions: [
                            ActionSet
                            {
                                title: header.title
                                subtitle: ListItemData.body
                                
                                ActionItem
                                {
                                    imageSource: "images/common/ic_copy.png"
                                    title: qsTr("Copy") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: CopyTafsirContentTriggered");
                                        var result = "";
                                        
                                        if (ListItemData.heading && ListItemData.heading.length > 0) {
                                            result += ListItemData.heading+"\n\n";
                                        }
                                        
                                        result += ListItemData.body;
                                        
                                        if (ListItemData.reference && ListItemData.reference.length > 0) {
                                            result += "\n\n"+ListItemData.reference;
                                        }
                                        
                                        persist.copyToClipboard( result.trim() );
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_edit_suite_page.png"
                                    title: qsTr("Edit") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: EditSuitePageContent");
                                        rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_move.png"
                                    title: qsTr("Move") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: MoveSuitePage");
                                        rootItem.ListItem.view.moveSuitePage(rootItem.ListItem.indexPath, ListItemData);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_help.png"
                                    title: qsTr("Quiz") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: Quiz");
                                        rootItem.ListItem.view.quiz(rootItem.ListItem.indexPath, ListItemData);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_set_marker.png"
                                    title: qsTr("Set Marker") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: SetSuitePageMarker");
                                        rootItem.ListItem.view.setSuitePageMarker(rootItem.ListItem);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_translate.png"
                                    title: qsTr("Translate") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: Translate");
                                        rootItem.ListItem.view.translateSuitePage(rootItem.ListItem.indexPath, ListItemData);
                                    }
                                }
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_delete_suite_page.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveSuitePage");
                                        rootItem.ListItem.view.removeItem(ListItemData);
                                        rootItem.ListItem.view.dataModel.removeAt(rootItem.ListItem.indexPath[0]);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "quote"
                    
                    StandardListItem
                    {
                        id: quoteSli
                        imageSource: "images/list/ic_quote.png"
                        title: ListItemData.title ? "%1 %2".arg(ListItemData.title).arg(ListItemData.reference) : ListItemData.reference
                        description: ListItemData.body
                        
                        contextActions: [
                            ActionSet
                            {
                                title: quoteSli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_delete_quote.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveQuote");
                                        quoteSli.ListItem.view.removeQuote(quoteSli.ListItem, ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
            
            function removeQuote(ListItem, ListItemData)
            {
                ilmHelper.removeQuote(listView, ListItemData.id);
                adm.removeAt(ListItem.indexPath[0]);
            }
            
            function itemType(data, indexPath)
            {
                if (data.author) {
                    return "quote";
                } else {
                    return "page";
                }
            }
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_suite_pages.png"
            labelText: qsTr("No elements found. Tap on the Add button to add a new one.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                addAction.triggered();
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_suite_pages.png"
        }
    }
    
    attachedObjects: [
        ActionItem
        {
            id: jumpToMarker
            imageSource: "images/menu/ic_set_marker.png"
            title: qsTr("Jump to Marker") + Retranslate.onLanguageChanged
            
            shortcuts: [
                Shortcut {
                    key: qsTr("J") + Retranslate.onLanguageChanged
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: JumpToMarker");
                var marker = persist.getValueFor("suitePageMarker");
                listView.scrollToItem([marker.indexPath], ScrollAnimation.None)
            }
        },
        
        SearchDecorator {
            id: decorator
        },
        
        SystemDialog
        {
            id: copyConfirm
            property variant destinationId
            title: qsTr("Copy Metadata?") + Retranslate.onLanguageChanged
            body: qsTr("Would you like to copy the title & reference metadata as well?") + Retranslate.onLanguageChanged
            confirmButton.label: qsTr("Yes") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("No") + Retranslate.onLanguageChanged
            includeRememberMe: true
            rememberMeChecked: false
            rememberMeText: qsTr("Delete collection after the transaction?") + Retranslate.onLanguageChanged
            
            onFinished: {
                var doCopy = value == SystemUiResult.ConfirmButtonSelection;
                
                busy.delegateActive = true;
                tafsirHelper.moveToSuite(listView, adm.value(listView.editIndexPath).id, destinationId, suiteId, rememberMeSelection());
                
                adm.removeAt(listView.editIndexPath[0]);
            } 
        }
    ]
}