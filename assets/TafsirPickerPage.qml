import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: tafsirPickerPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal tafsirPicked(variant data)
    signal totalLoaded(int size)
    property alias searchField: tftk.textField
    property alias autoFocus: focuser.running
    property alias suiteList: listView
    property alias filter: searchColumn.selectedValue
    property alias busyControl: busy.delegateActive
    property bool allowMultiple: false
    property variant exclusions: []
    
    actions: [
        ActionItem
        {
            imageSource: "images/menu/ic_add_suite.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            function onCreate(id, author, translator, explainer, title, description, reference, isBook)
            {
                var x = tafsirHelper.addSuite(author, translator, explainer, title, description, reference, isBook);
                tafsirHelper.fetchAllTafsir(listView, x.id);
                
                persist.showToast( qsTr("Suite added!"), "images/menu/ic_add_suite.png" );
                
                Qt.popToRoot(tafsirPickerPage);
                
                tafsirPicked([x]);
            }
            
            onTriggered: {
                console.log("UserEvent: NewSuite");
                var page = Qt.launch("CreateTafsirPage.qml");
                page.createTafsir.connect(onCreate);
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
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
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(tafsirPickerPage, listView, true);
        app.textualChange.connect(clearAndReload);
    }
    
    function cleanUp() {
        app.textualChange.disconnect(clearAndReload);
    }
    
    function clearAndReload()
    {
        adm.clear();
        reload();
    }
    
    function reload()
    {
        busy.delegateActive = true;
        tafsirHelper.fetchAllTafsir(listView, 0, 0, persist.getValueFor("optimizeQueries") == 1 ? 200 : 999999);
    }
    
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
                var query = textField.text.trim();
                
                if (query.length == 0) {
                    adm.clear();
                    reload();
                } else {
                    busy.delegateActive = true;
                    
                    var field = searchColumn.selectedValue;

                    if (field == titleOption.value && !titlesOnly.checked) {
                        field = "heading";
                    }
                    
                    tafsirHelper.searchTafsir(listView, field, query);
                }
            }
            
            onCreationCompleted: {
                textField.input["keyLayout"] = 7;
            }
        }
        
        acceptAction: ActionItem
        {
            id: titlesOnly
            imageSource: checked ? "images/dropdown/ic_short_narrations.png" : "images/dropdown/ic_any_narrations.png"
            property bool checked: true
            title: checked ? qsTr("Titles") + Retranslate.onLanguageChanged : qsTr("Headings") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: TitleHeadingTapped");
                checked = !checked;
                tftk.textField.requestFocus();
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_suites.png"
            labelText: qsTr("No suites matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                console.log("UserEvent: NoSuitesTapped");
                searchField.requestFocus();
            }
        }
        
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
                    imageSource: "images/dropdown/search_body.png"
                    text: qsTr("Body") + Retranslate.onLanguageChanged
                    value: "body"
                }
                
                Option {
                    imageSource: "images/dropdown/search_description.png"
                    text: qsTr("Description") + Retranslate.onLanguageChanged
                    value: "description"
                }
                
                Option {
                    imageSource: "images/dropdown/search_reference.png"
                    text: qsTr("Reference") + Retranslate.onLanguageChanged
                    value: "reference"
                }
                
                Option {
                    id: titleOption
                    imageSource: "images/dropdown/search_title.png"
                    selected: true
                    text: qsTr("Title") + Retranslate.onLanguageChanged
                    value: "title"
                }
            }
            
            ListView
            {
                id: listView
                property variant editIndexPath
                property variant destMergeId
                scrollRole: ScrollRole.Main

                multiSelectAction: MultiSelectActionItem {
                    imageSource: "images/menu/ic_select_more.png"                
                }
                
                onSelectionChanged: {
                    var n = selectionList().length;
                    multiSelectHandler.status = qsTr("%n suites selected", "", n);
                    selectMulti.enabled = n > 0;
                }
                
                multiSelectHandler.actions: [
                    ActionItem
                    {
                        id: selectMulti
                        enabled: false
                        imageSource: "images/menu/ic_accept.png"
                        title: qsTr("Select") + Retranslate.onLanguageChanged
                        
                        onTriggered: {
                            console.log("UserEvent: SelectMultipleTafsir");
                            
                            var all = listView.selectionList();
                            
                            for (var i = all.length-1; i >= 0; i--) {
                                all[i] = adm.data(all[i]);
                            }
                            
                            tafsirPicked(all);
                        }
                    },
                    
                    DeleteActionItem
                    {
                        imageSource: "images/menu/ic_remove_suite.png"
                        
                        onTriggered: {
                            console.log("UserEvent: DeleteMultiSuites");
                            
                            var all = listView.selectionList();
                            
                            for (var i = all.length-1; i >= 0; i--) {
                                listView.removeItem( adm.data(all[i]) );
                            }
                            
                            clearAndReload();
                        }
                    }
                ]
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function onEdit(id, author, translator, explainer, title, description, reference, isBook)
                {
                    busy.delegateActive = true;
                    var current = tafsirHelper.editSuite(listView, id, author, translator, explainer, title, description, reference, isBook);

                    dataModel.replace(editIndexPath[0], current);
                    
                    Qt.popToRoot(tafsirPickerPage);
                }
                
                function onDelete(id)
                {
                    removeItem({'id': id});
                    Qt.popToRoot(tafsirPickerPage);
                }
                
                function editItem(indexPath, ListItemData)
                {
                    editIndexPath = indexPath;
                    
                    var page = Qt.launch("CreateTafsirPage.qml");
                    page.suiteId = ListItemData.id;
                    page.createTafsir.connect(onEdit);
                    page.deleteTafsir.connect(onDelete);
                }
                
                function onActualPicked(suitesToMerge)
                {
                    var cleaned = [];
                    
                    for (var i = suitesToMerge.length-1; i >= 0; i--)
                    {
                        var current = suitesToMerge[i].id;
                        
                        if (current != destMergeId) {
                            cleaned.push(current);
                        }
                    }
                    
                    if (cleaned.length > 0)
                    {
                        busy.delegateActive = true;
                        tafsirHelper.mergeSuites(listView, cleaned, destMergeId);
                    } else {
                        persist.showToast( qsTr("The source and replacement suites cannot be the same!"), "images/toast/ic_duplicate_replace.png" );
                    }

                    Qt.popToRoot(tafsirPickerPage);
                }
                
                function merge(ListItemData)
                {
                    destMergeId = ListItemData.id;
                    var ipp = Qt.launch("TafsirPickerPage.qml");
                    ipp.allowMultiple = true;
                    ipp.autoFocus = true;
                    ipp.tafsirPicked.connect(onActualPicked);
                }
                
                function replace(toReplaceId, actualId)
                {
                    busy.delegateActive = true;
                    tafsirHelper.replaceSuite(listView, toReplaceId, actualId);
                    
                    Qt.popToRoot(tafsirPickerPage);
                }
                
                function removeItem(ListItemData) {
                    busy.delegateActive = true;
                    tafsirHelper.removeSuite(listView, ListItemData.id);
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        StandardListItem
                        {
                            id: rootItem
                            description: ListItemData.author ? ListItemData.author : qsTr("Unknown") + Retranslate.onLanguageChanged
                            imageSource: ListItemData.suite_page_id ? "images/list/ic_narration.png" : ListItemData.is_book ? "images/list/ic_book.png" : "images/list/ic_tafsir.png"
                            title: ListItemData.heading ? ListItemData.heading : ListItemData.title
                            status: ListItemData.c ? ListItemData.c : undefined
                            
                            contextActions: [
                                ActionSet
                                {
                                    title: rootItem.title
                                    subtitle: rootItem.description
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_edit_suite.png"
                                        title: qsTr("Edit") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: EditSuite");
                                            rootItem.ListItem.view.editItem(rootItem.ListItem.indexPath, ListItemData);
                                        }
                                    }
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_merge.png"
                                        title: qsTr("Merge") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: MergeSuite");
                                            rootItem.ListItem.view.merge(ListItemData);
                                        }
                                    }
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_replace_individual.png"
                                        title: qsTr("Replace") + Retranslate.onLanguageChanged
                                        enabled: ListItemData && !ListItemData.suite_page_id
                                        
                                        function onActualPicked(actualEntries) {
                                            rootItem.ListItem.view.replace(ListItemData.id, actualEntries[0].id);
                                        }
                                        
                                        onTriggered: {
                                            console.log("UserEvent: ReplaceSuite");
                                            var ipp = Qt.launch("TafsirPickerPage.qml");
                                            ipp.autoFocus = true;
                                            ipp.exclusions = [ListItemData.id];
                                            ipp.tafsirPicked.connect(onActualPicked);
                                        }
                                    }
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_remove_suite.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: AdminDeleteTafsirTriggered");
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
                    if (allowMultiple)
                    {
                        multiSelectHandler.active = true;
                        toggleSelection(indexPath);
                    } else {
                        console.log("UserEvent: AdminTafsirTriggered");
                        tafsirPicked( [dataModel.data(indexPath)] );
                    }
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllTafsir && data.length > 0)
                    {
                        adm.insert(0, data);
                        totalLoaded( adm.size() );
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    } else if (id == QueryId.RemoveSuite) {
                        persist.showToast( qsTr("Suite removed!"), "images/menu/ic_remove_suite.png" );
                    } else if (id == QueryId.EditSuite) {
                        persist.showToast( qsTr("Suite updated!"), "images/menu/ic_edit_suite.png" );
                    } else if (id == QueryId.SearchTafsir || id == QueryId.FindDuplicates) {
                        adm.clear();
                        adm.append(data);
                    } else if (id == QueryId.ReplaceSuite) {
                        persist.showToast( qsTr("Successfully merged suite!"), "images/menu/ic_replace_individual.png" );
                        clearAndReload();
                    }
                    
                    busy.delegateActive = false;
                    listView.visible = !adm.isEmpty();
                    noElements.delegateActive = !listView.visible;
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_suites.png"
        }
    }
    
    attachedObjects: [
        Timer {
            id: focuser
            interval: 250
            repeat: false
            running: false
            
            onTriggered: {
                tftk.textField.requestFocus();
            }
        }
    ]   
}