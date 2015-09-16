import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: choicePage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal picked(variant choiceId, string value)
    
    function performSearch() {
        ilmTest.fetchAllChoices( listView, tftk.textField.text.trim() );
    }
    
    actions: [
        ActionItem {
            id: searchAction
            imageSource: "images/menu/ic_search_choices.png"
            title: qsTr("Search") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SearchChoices");
                performSearch();
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
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
                    adm.clear();
                    adm.append(data);

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
                
                if ( d.source_id.toString().length == 0 )
                {
                    console.log("UserEvent: ChoicePicked");
                    picked(d.id, d.value_text);
                } else {
                    console.log("UserEvent: AliasTapped");
                }
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