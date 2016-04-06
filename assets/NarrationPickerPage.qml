import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: searchRoot
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property variant includedCollections: []
    signal picked(variant picked)
    
    function cleanUp() {}
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(searchRoot, listView);
        fader.play();
    }
    
    titleBar: TitleBar
    {
        id: tb
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            textField.hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
            textField.input.submitKey: SubmitKey.Submit
            textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.input.onSubmitted: {
                var trimmed = tftk.textField.text.trim();
                
                if (trimmed.length > 0)
                {
                    var elements = global.extractTokens(trimmed);

                    busy.delegateActive = true;
                    
                    var included = [];
                    
                    for (var i = includedCollections.length-1; i >= 0; i--) {
                        included.push(includedCollections[i].id);
                    }
                    
                    sunnah.searchNarrations(listView, elements, included, shortNarrations.checked);
                }
            }
        }
    }
    
    Container
    {
        id: searchContainer
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        CheckBox {
            id: shortNarrations
            horizontalAlignment: HorizontalAlignment.Fill
            text: qsTr("Short Narrations")
            checked: true
        }
        
        Button
        {
            horizontalAlignment: HorizontalAlignment.Fill
            text: qsTr("Search All Collections")
            opacity: 0
            
            function onPicked(all)
            {
                includedCollections = all;
                
                if (all.length > 0)
                {
                    var elements = [];
                    
                    for (var i = all.length-1; i >= 0; i--) {
                        elements.push(all[i].name);
                    }
                    
                    text = elements.join(", ");
                } else {
                    text = qsTr("Search All Collections");
                }
                
                while (navigationPane.top != searchRoot) {
                    navigationPane.pop();
                }
            }
            
            onClicked: {
                definition.source = "CollectionPickerPage.qml";
                var picker = definition.createObject();
                picker.picked.connect(onPicked);
                
                navigationPane.push(picker);
            }
            
            animations: [
                FadeTransition
                {
                    id: fader
                    fromOpacity: 0
                    toOpacity: 1
                    easingCurve: StockCurve.CubicIn
                    duration: 250

                    onEnded: {
                        tftk.textField.requestFocus();
                    }
                }
            ]
        }
        
        Container
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ListView
            {
                id: listView
                multiSelectHandler.actions: [
                    ActionItem
                    {
                        title: qsTr("Select")
                        
                        onTriggered: {
                            var all = listView.selectionList();
                            var result = [];

                            for (var i = all.length-1; i >= 0; i--) {
                                result.push( adm.data(all[i]) );
                            }

                            picked(result);
                        }
                    }
                ]

                dataModel: ArrayDataModel {
                    id: adm
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
                                title: ListItemData.name
                                subtitle: ListItemData.hadith_number
                            }
                            
                            Container
                            {
                                horizontalAlignment: HorizontalAlignment.Fill
                                leftPadding: 10; rightPadding: 10; bottomPadding: 10
                                
                                Label {
                                    id: bodyLabel
                                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                                    multiline: true
                                    text: ListItemData.body
                                }
                            }

                            contextActions: [
                                ActionSet {
                                    title: header.title
                                    subtitle: bodyLabel.text.substring( 0, Math.min(bodyLabel.text.length, 15) ).replace(/\n/g, " ")
                                    
                                    ActionItem {
                                        title: qsTr("Open") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            persist.invoke("com.canadainc.Sunnah10.shortcut", "bb.action.VIEW", "", "sunnah://id/"+ListItemData.narration_id);
                                            rootItem.ListItem.view.open(ListItemData);
                                        }
                                    }
                                }
                            ]
                        }
                    }
                ]
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SearchNarrations)
                    {
                        adm.clear();
                        adm.append(data);
                        busy.delegateActive = false;
                        noElements.delegateActive = adm.isEmpty();
                        listView.visible = !adm.isEmpty();
                        
                        if (listView.visible) {
                            offloader.decorateSearchResults(data, adm, global.extractTokens( tftk.textField.text.trim() ) );
                        }
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: HadithTriggeredFromSearch");
                    multiSelectHandler.active = true;
                    toggleSelection(indexPath);
                }
            }
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_centers.png"
                labelText: qsTr("No results matched your query.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: NoMatches");
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_choices.png"
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}