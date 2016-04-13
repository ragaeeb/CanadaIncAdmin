import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: individualPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property alias pickerList: listView
    property alias busyControl: busy
    property alias model: adm
    property alias searchField: tftk.textField
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
                    adm.insert(0, result);
                    refresh();
                    
                    persist.showToast( qsTr("Successfully added individual"), "images/menu/ic_select_individuals.png" );
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);

                    while (navigationPane.top != individualPage) {
                        navigationPane.pop();
                    }
                }
            }
            
            onTriggered: {
                console.log("UserEvent: NewIndividual");
                definition.source = "CreateIndividualPage.qml";
                var page = definition.createObject();
                page.createIndividual.connect(onCreate);
                
                navigationPane.push(page);
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
						imageSource = "images/dropdown/starts_with.png"; // starts with
                    } else if (flag == 2) {
                        imageSource = "images/list/ic_location.png"; // includes location only
                    } else if (flag == 3) {
                        imageSource = "images/menu/ic_remove_location.png"; // no locations
                    } else if (flag == 4) {
                        imageSource = "images/list/ic_companion.png"; // companions only
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: StartsWith");
                    if (flag == 4) {
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
                ilmHelper.searchIndividualsByDeath( listView, parseInt(trimmed) );
            } else {
                ilmHelper.searchIndividuals( listView, global.extractTokens(trimmed) );
            }
        } else {
            ilmHelper.fetchAllIndividuals(listView, flagAction.flag == 4, flagAction.flag == 2 ? true : flagAction.flag == 3 ? false : undefined);
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
                
                function openProfile(ListItemData)
                {
                    definition.source = "ProfilePage.qml";
                    var x = definition.createObject();
                    x.individualId = ListItemData.id;
                    
                    navigationPane.push(x);
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
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_preview.png"
                                        title: qsTr("View") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            console.log("UserEvent: OpenProfile");
                                            sli.ListItem.view.openProfile(ListItemData);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SearchIndividuals || id == QueryId.FetchAllIndividuals)
                    {
                        adm.clear();
                        adm.append(data);
                        
                        refresh();
                        
                        var trimmed = tftk.textField.text.trim();

                        if ( listView.visible && trimmed.length > 0 && !isDeathQuery(trimmed) ) {
                            offloader.decorateSearchResults(data, adm, global.extractTokens(trimmed), "display_name" );
                        }
                    }
                }
                
                onTriggered: {
                    var d = dataModel.data(indexPath);
                    console.log("UserEvent: IndividualPicked", d.display_name);
                    picked(d.id, d.display_name);
                }
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
        }
    ]
}