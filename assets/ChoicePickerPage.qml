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
    
    actions: [
        ActionItem
        {
            imageSource: "images/menu/ic_search_location.png"
            title: qsTr("Locations") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetLocationChoices");
                ilmTest.fetchChoicesWithIds( listView, ["32-43", 85, 86, "178-185", 913, 931, "950-962", 1047, "1527-1538", "1612-1613", "1617-1622", "1636-1637"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/menu/ic_search_rijaal.png"
            title: qsTr("Sects") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetSectChoices");
                ilmTest.fetchChoicesWithIds( listView, ["214-217", "317-322", 334, 507, "515-517", "530-532", 563, "579-583", "693-699", "805-810", "658-662", "1268-1270", "1276-1277", "1623-1626", "1683-1687", 1708] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/menu/ic_find_duplicate_quotes.png"
            title: qsTr("Occupations") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetOccupationChoices");
                ilmTest.fetchChoicesWithIds( listView, ["165-170", "916-920", 942, "979-987", "1049-1052"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/menu/ic_tribe.png"
            title: qsTr("Tribes") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetTribeChoices");
                ilmTest.fetchChoicesWithIds( listView, ["203-212", 1610] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/ic_percent.png"
            title: qsTr("Numeric") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetNumericChoices");
                ilmTest.fetchChoicesWithIds( listView, ["302-311"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/list/ic_book.png"
            title: qsTr("Books") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetBookChoices");
                ilmTest.fetchChoicesWithIds( listView, ["416-419", "1675-1682"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/list/ic_like.png"
            title: qsTr("Names of Allah") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetNamesOfAllahChoices");
                ilmTest.fetchChoicesWithIds( listView, [493, "495-499"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/menu/ic_edit_bio.png"
            title: qsTr("Fields") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetFieldsChoices");
                ilmTest.fetchChoicesWithIds( listView, ["508-514", "934-939", "1638-1639"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/menu/ic_preview.png"
            title: qsTr("Sins") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetSinsChoices");
                ilmTest.fetchChoicesWithIds( listView, ["589-594", 651, "839-840", "1698-1699"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/list/site_link.png"
            title: qsTr("Prayers") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetPrayerChoices");
                ilmTest.fetchChoicesWithIds( listView, ["678-686"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/list/ic_geo_search.png"
            title: qsTr("Rulings") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetRulingsChoices");
                ilmTest.fetchChoicesWithIds( listView, ["745-749", 758] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/list/ic_geo_result.png"
            title: qsTr("Schools") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetSchoolChoices");
                ilmTest.fetchChoicesWithIds( listView, ["923-930", "943-946", "972-978"] );
            }
        },
        
        ActionItem
        {
            imageSource: "images/tabs/ic_rijaal.png"
            title: qsTr("Angels") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: GetAngelChoices");
                ilmTest.fetchChoicesWithIds( listView, ["1086-1091", "1340-1343", "1399-1402", "1417-1418", "1484-1489", "1497-1508"] );
            }
        }
    ]
    
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
                        /*var useCustom = persist.showBlockingDialog( qsTr("New Choice"), qsTr("Do you want to add '%1' to the database?").arg(value) );

                        if (useCustom)
                        {
                            var x = ilmTest.addChoice(value);
                            picked(x.id, x.value_text);
                        } */
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
                    ListItemData = ilmTest.editChoice(listView, ListItemData.id, value);
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
                        persist.showToast( qsTr("Alias cannot be the same as the original!"), "images/toast/invalid_entry.png" );
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