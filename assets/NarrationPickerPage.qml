import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: searchRoot
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property variant includedCollections: []
    property alias narrationList: listView
    property variant collectionCodes: {'d': 1, 'a': 2, 'b': 3, 'g': 4, 'i': 5, 'k': 6, 'm': 7, 'n': 8, 'w': 9, 'q': 10, 'r': 11, 't': 12}
    signal picked(variant picked)
    function cleanUp() {}
    
    function isTurboQuery(term)
    {
        // w14 or w14-16
        var regex = new RegExp("^[a-w]{1}\\d{1,4}(-\\d{1,4}){0,1}$");
        var tokens = term.split(" ");
        
        for (var i = tokens.length-1 ; i >= 0; i--)
        {
            var current = tokens[i];
            
            if ( !regex.test(current) || !( current.charAt(0) in collectionCodes ) ) {
                return false;
            }
        }
        
        return true;
    }
    
    function populateAndSelect(data)
    {
        listView.onDataLoaded(QueryId.SearchNarrations, data);
        listView.selectAllOnLoad = true;
    }
    
    function popToRoot() {
        Qt.popToRoot(searchRoot);
    }
    
    actions: [
        ActionItem
        {
            ActionBar.placement: ActionBarPlacement.Signature
            imageSource: "images/menu/ic_search_append.png"
            title: qsTr("Append") + Retranslate.onLanguageChanged
            
            function onNarrationsSelected(all)
            {
                typos.reset();
                
                app.doDiff(all, adm, "narration_id");
                
                popToRoot();
                updateState();
                
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
            }
            
            onTriggered: {
                var searchPage = Qt.launch("NarrationPickerPage.qml");
                searchPage.picked.connect(onNarrationsSelected);
            }
        },
        
        ActionItem
        {
            id: selectAll
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_select_all_narrations.png"
            enabled: false
            title: qsTr("Select All") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: SelectAllNarrations");

                listView.multiSelectHandler.active = true;
                listView.selectAll();
            }
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
                
                if ( new RegExp("^\\d+$").test(trimmed) )
                {
                    var confirmed = persist.showBlockingDialog( qsTr("Confirmation"), qsTr("Are you sure you want to search just a number?") );
                    
                    if (!confirmed) {
                        return;
                    }
                }
                
                if (trimmed.length > 1)
                {
                    var i = 0;
                    
                    if ( isTurboQuery(trimmed) )
                    {
                        var terms = [];
                        var tokens = trimmed.split(" ");
                        
                        for (i = tokens.length-1; i >= 0; i--)
                        {
                            var current = tokens[i];
                            var range = current.split("-");
                            var collectionId = collectionCodes[range[0].charAt(0)];
                            var start = parseInt( range[0].substring(1) );
                            var end = range.length > 1 ? parseInt( range[1] ) : start;
                            
                            for (start; start <= end; start++) {
                                terms.push({'collection_id': collectionId, 'hadith_number': start.toString()});
                            }
                        }
                        
                        sunnah.fetchNarration(listView, terms);
                    } else {
                        var elements = global.extractTokens(trimmed);
                        
                        var included = [];
                        
                        for (i = includedCollections.length-1; i >= 0; i--) {
                            included.push(includedCollections[i].id);
                        }
                        
                        sunnah.searchNarrations(listView, elements, included, shortNarrations.checked);
                    }

                    busy.delegateActive = true;
                }
            }
        }
        
        onCreationCompleted: {
            tftk.textField.input["keyLayout"] = 7;
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
                
                typos.reset();
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
                popToRoot();
                tftk.textField.requestFocus();
            }
            
            onClicked: {
                var picker = Qt.launch("CollectionPickerPage.qml");
                picker.picked.connect(onPicked);
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
                
                function openNarration(narration)
                {
                    var page = Qt.launch("NarrationProfilePage.qml");
                    page.narrationId = narration.narration_id;
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

                            //typos.commit( result[0].narration_id );

                            picked(result);
                        }
                    },
                    
                    LinkActionItem {
                        id: linkAction
                    }
                ]
                
                multiSelectHandler.onActiveChanged: {
                    if (!active) {
                        listView.clearSelection();
                    }
                }
                
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
                        NarrationListItem
                        {
                            id: rootItem
                            horizontalAlignment: HorizontalAlignment.Fill
                            labelBackground: ListItemData.group_id ? Color.create(0,0.15,0) : SystemDefaults.Paints.ContainerBackground

                            ListItem.onInitializedChanged: {
                                if (initialized && ListItem.indexPath[0] == 0) {
                                    ListItem.view.loadingFinished();
                                }
                            }
                        }
                    }
                ]
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SearchNarrations || id == QueryId.FetchNarrations)
                    {
                        adm.clear();
                        adm.append(data);
                        updateState();

                        var trimmed = tftk.textField.text.trim();
                        
                        if ( listView.visible && trimmed.length > 0 && !isTurboQuery(trimmed) ) {
                            decorator.decorateSearchResults(data, adm, global.extractTokens(trimmed), "body" );
                        }
                        
                        if (id == QueryId.SearchNarrations && data.length == 0) {
                            typos.record(trimmed);
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
    
    function updateState()
    {
        busy.delegateActive = false;
        noElements.delegateActive = adm.isEmpty();
        listView.visible = !adm.isEmpty();
        selectAll.enabled = listView.visible;
    }
    
    attachedObjects: [
        TypoTrackerDialog
        {
            id: typos
            tableName: "narrations"
            
            onCorrectionsFound: {
                sunnah.fetchNarrations(listView, ids);
            }
        }
    ]
}