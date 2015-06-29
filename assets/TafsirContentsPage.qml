import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: tafsirContentsPage
    property variant suiteId
    property alias title: tb.title
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSuiteIdChanged: {
        if (suiteId)
        {
            busy.delegateActive = true;
            tafsirHelper.fetchAllTafsirForSuite(listView, suiteId);
            
            var marker = persist.getValueFor("suitePageMarker");
            
            if ( marker && (marker.suiteId == suiteId) ) {
                tafsirContentsPage.addAction(jumpToMarker);
            } else {
                tafsirContentsPage.removeAction(jumpToMarker);
            }
        }
    }
    
    function popToRoot()
    {
        while (navigationPane.top != tafsirContentsPage) {
            navigationPane.pop();
        }
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
                id = tafsirHelper.addTafsirPage(listView, suiteId, body, header, reference);
                
                var x = {'id': id, 'body': body, 'header': header, 'reference': reference};
                adm.insert(0, x);
            }
            
            onTriggered: {
                console.log("UserEvent: TafsirContentAddTriggered");

                definition.source = "CreateSuitePage.qml";
                var c = definition.createObject();
                c.createSuitePage.connect(onCreateSuitePage);
                c.focusable = true;
                
                navigationPane.push(c);
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
                    if ( adm.isEmpty() ) {
                        adm.append(data);
                    }
                    
                    if ( adm.isEmpty() ) {
                        addAction.triggered();
                    }
                } else if (id == QueryId.AddTafsirPage) {
                    persist.showToast( qsTr("Tafsir page added!"), "images/menu/ic_add_suite_page.png" );
                    popToRoot();
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                } else if (id == QueryId.MoveToSuite) {
                    persist.showToast( qsTr("Suite page moved!"), "images/menu/ic_merge.png" );
                } else if (id == QueryId.RemoveTafsirPage) {
                    persist.showToast( qsTr("Tafsir page removed!"), "images/menu/ic_delete_suite_page.png" );
                } else if (id == QueryId.EditTafsirPage) {
                    persist.showToast( qsTr("Tafsir page updated!"), "images/menu/ic_edit_suite_page.png" );
                    popToRoot();
                } else if (id == QueryId.TranslateSuitePage) {
                    persist.showToast( qsTr("Suite page ported!"), "images/menu/ic_edit_bio.png" );
                    persist.saveValueFor("translation", "arabic");
                }
                
                busy.delegateActive = false;
                listView.visible = !adm.isEmpty();
                noElements.delegateActive = !listView.visible;
            }
            
            function removeItem(ListItemData)
            {
                tafsirHelper.removeTafsirPage(listView, ListItemData.id);
                busy.delegateActive = true;
            }
            
            function onEditSuitePage(id, body, header, reference)
            {
                var x = dataModel.data(editIndexPath);
                x["body"] = body;
                x["heading"] = header;
                x["reference"] = reference;
                adm.replace(editIndexPath[0], x);
                
                tafsirHelper.editTafsirPage(listView, id, body, header, reference);
            }
            
            function editItem(indexPath, ListItemData)
            {
                editIndexPath = indexPath;
                definition.source = "CreateSuitePage.qml";
                var c = definition.createObject();
                c.createSuitePage.connect(onEditSuitePage);
                
                c.suitePageId = ListItemData.id;
                c.focusable = true;
                navigationPane.push(c);
            }
            
            function onActualPicked(destination)
            {
                var pickedId = destination[0].id;
                
                if (pickedId != suiteId)
                {
                    busy.delegateActive = true;
                    tafsirHelper.moveToSuite(listView, adm.value(editIndexPath).id, pickedId);
                    
                    adm.removeAt(editIndexPath[0]);
                } else {
                    persist.showToast( qsTr("The source and replacement suites cannot be the same!"), "images/toast/ic_duplicate_replace.png" );
                }
                
                popToRoot();
            }
            
            function moveSuitePage(indexPath, ListItemData)
            {
                editIndexPath = indexPath;
                definition.source = "TafsirPickerPage.qml";
                var ipp = definition.createObject();
                ipp.autoFocus = true;
                ipp.tafsirPicked.connect(onActualPicked);
                
                navigationPane.push(ipp);
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
            
            onTriggered: {
                console.log("UserEvent: TafsirContentTriggered");
                definition.source = "TafsirAyats.qml";
                var page = definition.createObject();
                page.suitePageId = dataModel.data(indexPath).id;
                
                navigationPane.push(page);
            }
            
            listItemComponents: [
                ListItemComponent
                {
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
                            text: ListItemData.body + (ListItemData.reference ? "\n\n"+ListItemData.reference : "")
                        }
                        
                        contextActions: [
                            ActionSet
                            {
                                title: header.title
                                subtitle: ListItemData.body
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_copy.png"
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
                                        console.log("UserEvent: EditTafsirContentTriggered");
                                        rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_bottom.png"
                                    title: qsTr("Move") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: MoveSuitePage");
                                        rootItem.ListItem.view.moveSuitePage(rootItem.ListItem.indexPath, ListItemData);
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
                                    imageSource: "images/menu/ic_merge.png"
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
                                        console.log("UserEvent: RemoveTafsirPageTriggered");
                                        rootItem.ListItem.view.removeItem(ListItemData);
                                        rootItem.ListItem.view.dataModel.removeAt(rootItem.ListItem.indexPath[0]);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
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
            
            onTriggered: {
                console.log("UserEvent: JumpToMarker");
                var marker = persist.getValueFor("suitePageMarker");
                listView.scrollToItem([marker.indexPath], ScrollAnimation.None)
            }
        }
    ]
}