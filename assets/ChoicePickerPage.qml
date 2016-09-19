import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: choicePage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal picked(variant values)
    
    function performSearch()
    {
        var query = tftk.textField.text.trim();
        
        ilmTest.fetchAllChoices(listView, query);
        salat.searchTags(listView, query, "grouped_choices");
    }
    
    titleBar: TitleBar
    {
        scrollBehavior: TitleBarScrollBehavior.NonSticky
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            
            textField {
                hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                input.keyLayout: KeyLayout.Text
                inputMode: TextFieldInputMode.Text
                input.submitKey: SubmitKey.Search
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: DoubleTappedChoiceField");
                            tftk.textField.text += persist.getClipboardText();
                        }
                    }
                ]
                
                input.onSubmitted: {
                    var value = textField.text.trim();
                    
                    if (value.length == 0) {
                        performSearch();
                    } else {
                        value = offloader.toTitleCase(value);
                        var x = ilmTest.addChoice(value);
                        picked([x]);
                    }
                }
                
                onTextChanging: {
                    if (text.trim().length > 0) {
                        performSearch();
                    }
                }
            }
        }
    }
    
    actions: [
        ActionItem
        {
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: "images/menu/ic_search_append.png"
            title: qsTr("Append") + Retranslate.onLanguageChanged
            
            function onPickedMulti(values)
            {
                app.doDiff(values, adm);
                
                Qt.popToRoot(choicePage);
                updateState();
                
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
            }
            
            onTriggered: {
                var searchPage = Qt.launch("ChoicePickerPage.qml");;
                searchPage.picked.connect(onPickedMulti);
            }
        }
    ]
    
    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_choices.png"
            labelText: qsTr("No results found for your query. Try another query.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                tftk.textField.requestFocus();
            }
        }
        
        ListView
        {
            id: listView
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function itemType(data, indexPath)
            {
                if (data.value_text) {
                    return "choice";
                } else {
                    return "tag";
                }
            }
            
            onSelectionChanged: {
                var n = selectionList().length;
                multiSelectHandler.status = qsTr("%n choices selected", "", n);
                selectMulti.enabled = n > 0;
                linkChoices.enabled = n > 1;
            }
            
            multiSelectHandler.actions: [
                ActionItem
                {
                    id: selectMulti
                    enabled: false
                    imageSource: "images/menu/ic_accept_choices.png"
                    title: qsTr("Select") + Retranslate.onLanguageChanged
                    
                    onTriggered: {
                        console.log("UserEvent: SelectMultiChoices");
                        
                        var all = listView.selectionList();
                        var result = [];
                        
                        for (var i = all.length-1; i >= 0; i--)
                        {
                            var d = adm.data(all[i]);
                            
                            if (d.value_text) { // make sure it's not a tag
                                result.push(d);
                            }
                        }
                        
                        picked(result);
                    }
                },
                
                LinkChoicesAction {
                    id: linkChoices
                }
            ]
            
            function editChoice(ListItem, ListItemData)
            {
                var value = ListItemData.value_text;
                value = persist.showBlockingPrompt( qsTr("Enter choice text"), qsTr("Please enter the new value of this choice:"), value, qsTr("Enter value"), 100, true, qsTr("Save"), qsTr("Cancel") ).trim();
                
                if (value.length > 0)
                {
                    ilmTest.editChoice(listView, ListItemData.id, value);
                    ListItemData.value_text = value;
                    adm.replace(ListItem.indexPath[0], ListItemData);
                }
            }
            
            function removeChoice(ListItem, ListItemData)
            {
                ilmTest.removeChoice(listView, ListItemData.id);
                adm.removeAt(ListItem.indexPath[0]);
            }
            
            function findAdjacent(ListItem, ListItemData) {
                ilmTest.fetchAdjacentChoices(listView, ListItemData.source_id.toString().length == 0 ? ListItemData.id : ListItemData.source_id);
            }
            
            function sourceChoice(ListItem, ListItemData)
            {
                var value = ListItemData.value_text;
                var aliasValue = persist.showBlockingPrompt( qsTr("Enter choice text"), qsTr("Please enter an alias for this choice:"), "", qsTr("Enter value"), 100, true, qsTr("Save"), qsTr("Cancel") ).trim();
                
                if (aliasValue.length > 0)
                {
                    aliasValue = offloader.toTitleCase(aliasValue);
                    
                    if (value != aliasValue) {
                        var copy = ilmTest.sourceChoice(ListItemData.id, aliasValue);
                        adm.insert(ListItem.indexPath[0], copy);
                    } else {
                        persist.showToast( qsTr("Alias cannot be the same as the original!"), "images/toast/question_entry_warning.png" );
                    }
                }
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "choice"
                    
                    ChoiceListItem
                    {
                        id: sli
                        property bool nonAlias: ListItemData.source_id.toString().length == 0
                        opacity: nonAlias ? 1 : 0.7
                        status: ListItemData.id.toString()
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sli.title
                                subtitle: sli.status
                                
                                ActionItem
                                {
                                    title: qsTr("Edit") + Retranslate.onLanguageChanged
                                    imageSource: "images/menu/ic_edit_choice.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: EditChoice");
                                        sli.ListItem.view.editChoice(sli.ListItem, ListItemData);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_source_choice.png"
                                    enabled: sli.nonAlias
                                    title: qsTr("Create Alias") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: SourceChoice");
                                        sli.ListItem.view.sourceChoice(sli.ListItem, ListItemData);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_adjacent_choices.png"
                                    title: qsTr("Find Adjacent") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: FindAdjacent");
                                        sli.ListItem.view.findAdjacent(sli.ListItem, ListItemData);
                                    }
                                }
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_choice.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveChoice");
                                        sli.ListItem.view.removeChoice(sli.ListItem, ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "tag"
                    
                    StandardListItem
                    {
                        id: tagRoot
                        imageSource: "images/list/ic_tag.png"
                        title: ListItemData.tag
                    }
                }
            ]
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchAllChoices)
                {
                    adm.clear();
                    adm.append(data);
                    updateState();
                } else if (id == QueryId.SearchTags || id == QueryId.FetchAdjacentChoices) {
                    app.doDiff(data, adm);
                    updateState();
                } else if (id == QueryId.AddChoice) {
                    persist.showToast( qsTr("Choice added!"), "images/menu/ic_add_choice.png" );
                } else if (id == QueryId.RemoveChoice) {
                    persist.showToast( qsTr("Choice removed!"), "images/menu/ic_remove_choice.png" );
                } else if (id == QueryId.EditChoice) {
                    persist.showToast( qsTr("Choice updated!"), "images/menu/ic_edit_choice.png" );
                }
            }
            
            onTriggered: {
                var d = dataModel.data(indexPath);
                
                console.log("UserEvent: ChoicePicked");
                
                if ( itemType(d, indexPath) == "tag" ) {
                    ilmTest.fetchChoicesForTag(listView, d.tag);
                } else {
                    multiSelectHandler.active = true;
                    toggleSelection(indexPath);
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_choices.png"
        }
    }
    
    function updateState()
    {
        busy.delegateActive = false;
        noElements.delegateActive = adm.isEmpty();
        listView.visible = !adm.isEmpty();
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(choicePage, listView);
    }
    
    function cleanUp() {}
    
    attachedObjects: [
        Timer {
            interval: 50
            repeat: false
            running: true
            
            onTriggered: {
                tftk.textField.requestFocus();
            }
        }
    ]
}