import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: searchRoot
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property variant includedCollections: []
    property variant collectionCodes: {'d': 1, 'a': 2, 'b': 3, 'g': 4, 'i': 5, 'k': 6, 'm': 7, 'n': 8, 'w': 9, 'q': 10, 'r': 11, 't': 12}
    signal picked(variant picked)
    
    function cleanUp() {}
    
    function isTurboQuery(term) {
        return new RegExp("^[a-w]{1}\\d{1,4}$").test(term) && ( term.charAt(0) in collectionCodes );
    }
    
    function populateAndSelect(data)
    {
        listView.onDataLoaded(QueryId.SearchNarrations, data);
        listView.selectAllOnLoad = true;
    }
    
    actions: [
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
                    if ( isTurboQuery(trimmed) ) {
                        sunnah.fetchNarration(listView, collectionCodes[trimmed.charAt(0)], trimmed.substring(1));
                    } else {
                        var elements = global.extractTokens(trimmed);
                        
                        var included = [];
                        
                        for (var i = includedCollections.length-1; i >= 0; i--) {
                            included.push(includedCollections[i].id);
                        }
                        
                        sunnah.searchNarrations(listView, elements, included, shortNarrations.checked);
                    }

                    busy.delegateActive = true;
                }
            }
        }
        
        acceptAction: ActionItem
        {
            id: shortNarrations
            imageSource: checked ? "images/dropdown/ic_short_narrations.png" : "images/dropdown/ic_any_narrations.png"
            property bool checked: true
            title: checked ? qsTr("Short") + Retranslate.onLanguageChanged : qsTr("Any") + Retranslate.onLanguageChanged

            onTriggered: {
                console.log("UserEvent: ShortNarrationsTapped");
                checked = !checked;
                tftk.textField.requestFocus();
            }
        }
    }
    
    Container
    {
        id: searchContainer
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Button
        {
            id: collectionButton
            horizontalAlignment: HorizontalAlignment.Fill
            opacity: 0
            
            function process(all)
            {
                includedCollections = all;
                
                if (all.length > 0)
                {
                    var elements = [];
                    
                    for (var i = all.length-1; i >= 0; i--) {
                        elements.push(all[i].name);
                    }
                    
                    text = elements.join(", ");
                    imageSource = "images/dropdown/ic_search_specific.png";
                } else {
                    text = qsTr("Search All Collections");
                    imageSource = "images/dropdown/ic_search_all_collections.png";
                }
            }
            
            function onPicked(all)
            {
                process(all);
                global.popToRoot(navigationPane, searchRoot);
                tftk.textField.requestFocus();
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
                        collectionButton.process([]);
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
                property bool selectAllOnLoad: false
                
                function loadingFinished()
                {
                    if (selectAllOnLoad)
                    {
                        multiSelectHandler.active = true;
                        selectAll();
                    }
                }

                multiSelectHandler.actions: [
                    ActionItem
                    {
                        id: accept
                        imageSource: "images/menu/ic_accept_narrations.png"
                        title: qsTr("Select") + Retranslate.onLanguageChanged
                        
                        onTriggered: {
                            var all = listView.selectionList();
                            var result = [];

                            for (var i = all.length-1; i >= 0; i--) {
                                result.push( adm.data(all[i]) );
                            }

                            picked(result);
                        }
                    },
                    
                    LinkActionItem {
                        id: linkAction
                    }
                ]
                
                onSelectionChanged: {
                    var n = selectionList().length;
                    linkAction.enabled = n > 1;
                    accept.enabled = n > 0;
                }

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

                            ListItem.onInitializedChanged: {
                                if (initialized && ListItem.indexPath[0] == 0) {
                                    ListItem.view.loadingFinished();
                                }
                            }

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
                                ActionSet
                                {
                                    title: header.title
                                    subtitle: bodyLabel.text.substring( 0, Math.min(bodyLabel.text.length, 15) ).replace(/\n/g, " ")
                                    
                                    ActionItem
                                    {
                                        imageSource: "images/menu/ic_preview_hadith.png"
                                        title: qsTr("Open") + Retranslate.onLanguageChanged
                                        
                                        onTriggered: {
                                            persist.invoke("com.canadainc.Sunnah10.shortcut", "bb.action.VIEW", "", "sunnah://id/"+ListItemData.narration_id);
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
                        var trimmed = tftk.textField.text.trim();
                        
                        if ( listView.visible && trimmed.length > 0 && !isTurboQuery(trimmed) ) {
                            decorator.decorateSearchResults(data, adm, global.extractTokens(trimmed), "body" );
                        }
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: HadithTriggeredFromSearch");
                    multiSelectHandler.active = true;
                    toggleSelection(indexPath);
                }
                
                attachedObjects: [
                    SearchDecorator {
                        id: decorator
                    }
                ]
            }
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_narrations.png"
                labelText: qsTr("No results matched your query.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: NoMatches");
                    shortNarrations.triggered();
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_narrations.png"
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}