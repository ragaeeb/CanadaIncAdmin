import bb.cascades 1.3
import bb.system 1.2
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    property alias searchField: tftk.textField
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function reload()
    {
        busy.delegateActive = true;
        sunnah.fetchGroupedNarrations(listView);
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(narrationPage, listView, true);
        reload();
    }
    
    Page
    {
        id: narrationPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar
        {
            kind: TitleBarKind.TextField
            kindProperties: TextFieldTitleBarKindProperties
            {
                id: tftk
                textField.hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
                textField.input.submitKey: SubmitKey.Search
                textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                textField.input.onSubmitted: {
                    var query = searchField.text.trim();
                    
                    if (query.length == 0) {
                        reload();
                    } else {
                        busy.delegateActive = true;
                    }
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                ListView
                {
                    id: listView
                    scrollRole: ScrollRole.Main
                    property int totalSelected: 0
                    
                    onSelectionChanged: {
                        totalSelected = selectionList().length;
                    }
                    
                    multiSelectHandler.actions: [
                        ActionItem
                        {
                            id: link
                            imageSource: "images/menu/ic_relink.png"
                            title: qsTr("Link") + Retranslate.onLanguageChanged
                            enabled: listView.totalSelected > 1
                            property variant selectedData
                            
                            function onPicked(groupNumber)
                            {
                                if (groupNumber == 0) {
                                    groupNumber = gdm.data( gdm.last() ).group_number+1; // to guarantee we'll get a unique new group number
                                }
                                
                                var result = [];
                                var i = 0;
                                
                                for (i = selectedData.length-1; i >= 0; i--)
                                {
                                    var current = selectedData[i];
                                    result.push(current.id);
                                    
                                    if (current.group_number != groupNumber)
                                    {
                                        gdm.remove(current);

                                        current.group_number = groupNumber;
                                        gdm.insert(current);
                                    }
                                }

                                sunnah.updateGroupNumber(listView, result, groupNumber);
                                
                                while (navigationPane.top != narrationPage) {
                                    navigationPane.pop();
                                }
                            }
                            
                            onTriggered: {
                                console.log("UserEvent: LinkNarrations");
                                
                                var all = listView.selectionList();
                                var result = [];
                                
                                for (var i = all.length-1; i >= 0; i--) {
                                    result.push( gdm.data(all[i]) );
                                }
                                
                                definition.source = "NarrationGroupPicker.qml";
                                var ngp = definition.createObject();
                                ngp.picked.connect(onPicked);
                                ngp.apply(result);
                                
                                selectedData = result;
                                navigationPane.push(ngp);
                            }
                        },
                        
                        DeleteActionItem
                        {
                            id: unlinkSimilar
                            imageSource: "images/menu/ic_unlink.png"
                            title: qsTr("Unlink") + Retranslate.onLanguageChanged
                            enabled: listView.totalSelected > 0

                            onTriggered: {
                                console.log("UserEvent: UnlinkNarrationsFromOthers");

                                var all = listView.selectionList();
                                var result = [];
                                
                                for (var i = all.length-1; i >= 0; i--)
                                {
                                    var current = gdm.data(all[i]);
                                    result.push(current.id);
                                    gdm.remove(current);
                                }
                                
                                sunnah.unlinkNarrationFromSimilar(listView, result);
                            }
                        }
                    ]
                    
                    dataModel: GroupDataModel
                    {
                        id: gdm
                        grouping: ItemGrouping.ByFullValue
                        sortingKeys: ["group_number", "name", "hadith_number"]
                    }
                    
                    function loadingFinished() {
                        busy.delegateActive = false;
                    }
                    
                    function onDataLoaded(id, data)
                    {
                        if (id == QueryId.FetchGroupedNarrations)
                        {
                            navigationPane.parent.unreadContentCount = data.length;
                            gdm.clear();
                            gdm.insertList(data);
                            
                            listView.visible = !gdm.isEmpty();
                        } else if (id == QueryId.UnlinkNarrationsFromSimilar) {
                            persist.showToast( qsTr("Related narrations unlinked!"), unlinkSimilar.imageSource.toString()  );
                        } else if (id == QueryId.UpdateGroupNumbers) {
                            persist.showToast( qsTr("Related narrations moved!"), link.imageSource.toString()  );
                        }
                    }
                    
                    listItemComponents: [
                        ListItemComponent
                        {
                            type: "header"
                            
                            Header {
                                title: ListItemData.toString()
                                
                                ListItem.onInitializedChanged: {
                                    if (initialized && ListItem.indexPath[0] == 0) {
                                        ListItem.view.loadingFinished();
                                    }
                                }
                            }
                        },
                        
                        ListItemComponent
                        {
                            type: "item"
                            
                            NarrationListItem {}
                        }
                    ]
                    
                    onTriggered: {
                        console.log("UserEvent: SimilarHadithTap");
                        multiSelectHandler.active = true;
                        toggleSelection(indexPath);
                    }
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_similar.png"
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}