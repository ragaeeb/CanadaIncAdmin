import QtQuick 1.0
import bb.cascades 1.3
import bb.system 1.2
import com.canadainc.data 1.0

Page
{
    id: individualPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property alias pickerList: listView
    property alias busyControl: busy
    property alias model: adm
    property alias searchField: tftk.textField
    property variant exclusions: []
    signal picked(variant individualId, string name)
    signal contentLoaded(int size)
    
    function isDeathQuery(term) {
        return new RegExp("^\\d{1,4}$").test(term);
    }
    
    actions: [
        ActionItem
        {
            id: addAction
            imageSource: "images/menu/ic_add_rijaal.png"
            title: qsTr("Add") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            function onCreate(id, prefix, name, kunya, displayName, hidden, birth, death, female, location, currentLocation, companion, description)
            {
                var result = ilmHelper.addIndividual(prefix, name, kunya, displayName, hidden, birth, death, female, location, currentLocation, companion, description);
                
                if (result.id)
                {
                    typos.reset();
                    
                    adm.insert(0, result);
                    refresh();
                    
                    persist.showToast( qsTr("Successfully added individual"), "images/menu/ic_select_individuals.png" );
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);

                    Qt.popToRoot(individualPage);
                }
            }
            
            onTriggered: {
                console.log("UserEvent: NewIndividual");
                var page = Qt.launch("CreateIndividualPage.qml");
                page.createIndividual.connect(onCreate);
            }
        },
        
        DeleteActionItem
        {
            imageSource: "images/menu/ic_reset_fields.png"
            title: qsTr("Reset") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: ResetFields");
                
                tftk.textField.resetText();
                timer.restart();
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
            textField.input.submitKey: SubmitKey.Next
            textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.input.onSubmitted: {
                performSearch();
            }
            
            textField.gestureHandlers: [
                DoubleTapHandler {
                    onDoubleTapped: {
                        console.log("UserEvent: DoubleTappedIndividualSearch");
                        tftk.textField.text = persist.getClipboardText();
                    }
                }
            ]
            
            onCreationCompleted: {
                tftk.textField.input["keyLayout"] = 7;
            }
        }
        
        acceptAction: [
            ActionItem {
                id: flagAction
                property int flag: 0
                
                onCreationCompleted: {
                    update();
                }
                
                function update()
                {
                    if (flag == 0) {
                        imageSource = "images/menu/ic_search_rijaal.png"; // standard contains
                    } else if (flag == 1) {
                        imageSource = "images/list/ic_companion.png"; // companions only
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: StartsWith");
                    if (flag == 1) {
                        flag = 0;
                    } else {
                        ++flag;
                    }
                    
                    update();
                    tftk.textField.requestFocus();
                }
            }
        ]
    }
    
    function performSearch()
    {
        var trimmed = searchField.text.trim();
        
        if (trimmed.length > 0)
        {
            busy.delegateActive = true;
            noElements.delegateActive = false;
            
            if ( isDeathQuery(trimmed) ) {
                ilmHelper.searchIndividualsByDeath( listView, parseInt(trimmed), exclusions );
            } else {
                ilmHelper.searchIndividuals( listView, global.extractTokens(trimmed), exclusions );
            }
        } else {
            ilmHelper.fetchAllIndividuals(listView, flagAction.flag == 1);
        }
    }
    
    function refresh()
    {
        contentLoaded( adm.size() );
        busy.delegateActive = false;
        noElements.delegateActive = adm.isEmpty();
        listView.visible = !adm.isEmpty();
    }
    
    function cleanUp() {
        app.textualChange.disconnect(performSearch);
    }
    
    onCreationCompleted: {
        app.textualChange.connect(performSearch);
        deviceUtils.attachTopBottomKeys(individualPage, listView);
    }
    
    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_individuals.png"
            labelText: qsTr("No results found for your query. Try another query.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                searchField.requestFocus();
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ListView
            {
                id: listView
                property alias pickerPage: individualPage
                scrollRole: ScrollRole.Main
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        IndividualListItem
                        {
                            id: sli

                            contextActions: [
                                ActionSet
                                {
                                    title: sli.title
                                    subtitle: sli.description
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/common/ic_copy.png"
                                        title: qsTr("Copy") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: CopyIndividual");
                                            persist.copyToClipboard( global.plainText(sli.title) );
                                        }
                                    }
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_replace_individual.png"
                                        title: qsTr("Replace") + Retranslate.onLanguageChanged
                                        
                                        function onActualPicked(actualId) {
                                            sli.ListItem.view.replace(ListItemData.id, actualId);
                                        }
                                        
                                        onTriggered: {
                                            console.log("UserEvent: ReplaceIndividual");
                                            var ipp = Qt.launch("IndividualPickerPage.qml");
                                            ipp.exclusions = [ListItemData.id];
                                            ipp.picked.connect(onActualPicked);
                                        }
                                    }
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_preview.png"
                                        title: qsTr("View") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: OpenProfile");

                                            var x = Qt.launch("ProfilePage.qml");
                                            x.individualId = ListItemData.id;
                                        }
                                    }
                                    
                                    DeleteActionItem
                                    {
                                        imageSource: "images/menu/ic_delete_individual.png"
                                        
                                        onTriggered: {
                                            console.log("UserEvent: DeleteIndividual");
                                            sli.ListItem.view.removeItem(sli.ListItem, ListItemData);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                function removeItem(ListItem, ListItemData)
                {
                    busy.delegateActive = true;
                    ilmHelper.removeIndividual(listView, ListItemData.id);
                    adm.removeAt(ListItem.indexPath[0]);
                }
                
                function replace(toReplaceId, actualId)
                {
                    busy.delegateActive = true;
                    ilmHelper.replaceIndividual(listView, toReplaceId, actualId);
                    
                    Qt.popToRoot(individualPage);
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SearchIndividuals || id == QueryId.FetchAllIndividuals)
                    {
                        adm.clear();
                        adm.append(data);
                        
                        refresh();
                        
                        var trimmed = tftk.textField.text.trim();

                        if ( listView.visible && trimmed.length > 0 && !isDeathQuery(trimmed) ) {
                            decorator.decorateSearchResults(data, adm, global.extractTokens(trimmed), "display_name" );
                        }
                    } else if (id == QueryId.RemoveIndividual) {
                        persist.showToast( qsTr("Successfully deleted individual!"), "images/menu/ic_delete_individual.png" );
                        refresh();
                    } else if (id == QueryId.ReplaceIndividual) {
                        persist.showToast( qsTr("Successfully replaced individual!"), "images/menu/ic_replace_individual.png" );
                        performSearch();
                    }
                    
                    if (id == QueryId.SearchIndividuals && data.length == 0) {
                        typos.record( tftk.textField.text.trim() );
                    }
                }
                
                onTriggered: {
                    var d = dataModel.data(indexPath);
                    console.log("UserEvent: IndividualPicked", d.display_name);
                    
                    var resultId = d.id;
                    
                    //typos.commit(resultId);
                    
                    picked(resultId, d.display_name);
                }
                
                attachedObjects: [
                    SearchDecorator {
                        id: decorator
                    }
                ]
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_individuals.png"
        }
    }
    
    attachedObjects: [
        Timer {
            id: timer
            interval: 250
            repeat: false
            running: true
            
            onTriggered: {
                tftk.textField.requestFocus();
            }
        },
        
        TypoTrackerDialog
        {
            id: typos
            tableName: "individuals"
            
            onCorrectionsFound: {
                ilmHelper.fetchAllIndividuals(listView, false, ids);
            }
        }
    ]
}