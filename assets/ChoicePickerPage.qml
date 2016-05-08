import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: choicePage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal picked(variant choiceId, string value)
    signal pickedMulti(variant values)
    
    function performSearch() {
        ilmTest.fetchAllChoices( listView, tftk.textField.text.trim() );
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
                        picked(x.id, x.value_text);
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
            
            onSelectionChanged: {
                var n = selectionList().length;
                multiSelectHandler.status = qsTr("%n choices selected", "", n);
                selectMulti.enabled = n > 0;
            }
            
            multiSelectAction: MultiSelectActionItem {
                imageSource: "images/menu/ic_select_choices.png"
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

                            if ( d.source_id.toString().length == 0 ) {
                                result.push(d);
                            }
                        }
                        
                        pickedMulti(result);
                    }
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
                    StandardListItem
                    {
                        id: sli
                        imageSource: "images/list/ic_choice.png"
                        title: ListItemData.value_text
                        enabled: ListItemData.source_id.toString().length == 0
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
                                    enabled: sli.enabled
                                    title: qsTr("Create Alias") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: SourceChoice");
                                        sli.ListItem.view.sourceChoice(sli.ListItem, ListItemData);
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
                }
            ]
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchAllChoices)
                {
                    if ( data.length == adm.size() )
                    {
                        for (var i = data.length-1; i >= 0; i--) {
                            adm.replace(i, data[i]);
                        }
                    } else {
                        adm.clear();
                        adm.append(data);
                    }

                    busy.delegateActive = false;
                    noElements.delegateActive = adm.isEmpty();
                    listView.visible = !adm.isEmpty();
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
                picked( d.source_id.toString().length == 0 ? d.id : d.source_id, d.value_text );
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_choices.png"
        }
    }
    
    function createAction(imageSource, title, data)
    {
        var x = actionDef.createObject();
        x.imageSource = imageSource;
        x.title = title;
        x.data = data;
        
        return x;
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(choicePage, listView);
        
        addAction( createAction("images/menu/ic_search_location.png", qsTr("Locations"), ["32-43", 85, 86, "178-185", 913, 931, "950-962", 1047, "1527-1538", "1612-1613", "1617-1622", "1636-1637"]) );
        addAction( createAction("images/menu/ic_search_rijaal.png", qsTr("Sects"), ["214-217", "317-322", 334, 507, "515-517", "530-532", 563, "579-583", "693-699", "805-810", "658-662", "1268-1270", "1276-1277", "1623-1626", "1683-1687", 1708]) );
        addAction( createAction("images/menu/ic_tribe.png", qsTr("Tribes"), ["203-212", 1610]) );
        addAction( createAction("images/menu/ic_find_duplicate_quotes.png", qsTr("Occupations"), ["165-170", "916-920", 942, "979-987", "1049-1052"]) );
        addAction( createAction("images/list/ic_book.png", qsTr("Books"), ["416-419", "1675-1682"]) );
        addAction( createAction("images/list/ic_like.png", qsTr("Names of Allah"), [493, "495-499"]) );
        addAction( createAction("images/menu/ic_edit_bio.png", qsTr("Fields"), ["508-514", "934-939", "1638-1639"]) );
        addAction( createAction("images/menu/ic_preview.png", qsTr("Sins"), ["589-594", 651, "839-840", "1698-1699"]) );
        addAction( createAction("images/list/site_link.png", qsTr("Prayers"), ["678-686"]) );
        addAction( createAction("images/list/ic_geo_result.png", qsTr("Schools"), ["923-930", "943-946", "972-978"]) );

        titleBar.acceptAction = createAction("images/list/ic_geo_search.png", qsTr("Rulings"), ["745-749", 758]);
        titleBar.dismissAction = createAction("images/tabs/ic_rijaal.png", qsTr("Angels"), ["1086-1091", "1340-1343", "1399-1402", "1417-1418", "1484-1489", "1497-1508"]);
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
        },
        
        ComponentDefinition
        {
            id: actionDef
            
            ActionItem
            {
                property variant data
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: Get"+title.split(" ").join("")+"Choices" )
                    ilmTest.fetchChoicesWithIds(listView, data);
                }
            }
        }
    ]
}