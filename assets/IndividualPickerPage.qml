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
            
            function onCreate(id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion)
            {
                id = tafsirHelper.createIndividual(listView, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion);

                var obj = {'id': id, 'name': name, 'hidden': hidden ? 1 : undefined, 'female': female ? 1 : undefined, 'is_companion': companion ? 1 : undefined};

                if (displayName.length > 0) {
                    obj["name"] = displayName;
                }
                
                if (birth > 0) {
                    obj["birth"] = birth;
                }
                
                if (death > 0) {
                    obj["death"] = death;
                }
                
                if (location.length > 0) {
                    obj["location"] = location;
                }

                adm.insert(0, obj);
                refresh();
            }
            
            onTriggered: {
                console.log("UserEvent: NewIndividual");
                definition.source = "CreateIndividualPage.qml";
                var page = definition.createObject();
                page.createIndividual.connect(onCreate);
                
                navigationPane.push(page);
            }
        },
        
        TextInputActionItem
        {
            id: andConstraint
            hintText: qsTr("AND...") + Retranslate.onLanguageChanged
            input.submitKey: SubmitKey.Search
            input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            input.onSubmitted: {
                performSearch();
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
            textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.input.onSubmitted: {
                performSearch();
            }
        }
    }
    
    function performSearch()
    {
        var trimmed = searchField.text.trim();
        
        if (trimmed.length > 0)
        {
            busy.delegateActive = true;
            noElements.delegateActive = false;
            
            tafsirHelper.searchIndividuals( listView, trimmed, andConstraint.text.trim() );
        } else {
            tafsirHelper.fetchAllIndividuals(listView);
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
                        StandardListItem
                        {
                            id: sli
                            imageSource: ListItemData.hidden ? "images/list/ic_hidden.png" : ListItemData.is_companion ? "images/list/ic_companion.png" : "images/list/ic_individual.png"
                            title: ListItemData.display_name
                            
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
                    } else if (id == QueryId.AddIndividual) {
                        persist.showToast( qsTr("Successfully added individual"), "images/menu/ic_select_individuals.png" );
                        scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                        
                        while (navigationPane.top != individualPage) {
                            navigationPane.pop();
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
            interval: 250
            repeat: false
            running: true
            
            onTriggered: {
                tftk.textField.requestFocus();
            }
        }
    ]
}