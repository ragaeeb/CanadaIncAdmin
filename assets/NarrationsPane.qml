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
    
    function updateSelectedGroup(all, groupNumber)
    {
        var removedValues = [];
        var result = [];
        var i = 0;
        
        for (i = all.length-1; i >= 0; i--)
        {
            var current = gdm.data(all[i]);
            result.push(current.id);
            gdm.remove(current);
            
            current.group_number = groupNumber;
            removedValues.push(current);
        }
        
        for (i = removedValues.length-1; i >= 0; i--) {
            gdm.insert(removedValues[i]);
        }
        
        sunnah.updateGroupNumber(listView, result, groupNumber);
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
                            imageSource: "images/menu/ic_reorder_suites.png"
                            title: qsTr("Link") + Retranslate.onLanguageChanged
                            enabled: listView.totalSelected > 1
                            
                            onTriggered: {
                                console.log("UserEvent: LinkNarrations");
                                
                                targetDialog.clearList();
                                var all = listView.selectionList();
                                
                                for (var i = 0; i < all.length; i++)
                                {
                                    var current = gdm.data(all[i]);
                                    targetDialog.appendItem( current.name+" #"+current.hadith_number, true, i == 0 );
                                }
                                
                                targetDialog.selectedPaths = all;
                                targetDialog.show();
                            }
                            
                            attachedObjects: [
                                SystemListDialog
                                {
                                    id: targetDialog
                                    property variant selectedPaths
                                    title: qsTr("Choose Target Group") + Retranslate.onLanguageChanged
                                    body: qsTr("Which is the correct hadith group you want to move these narrations into?") + Retranslate.onLanguageChanged
                                    cancelButton.label: qsTr("Cancel")
                                    confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged

                                    onFinished: {
                                        if (value == SystemUiResult.ConfirmButtonSelection)
                                        {
                                            var index = selectedIndices[0];
                                            var groupNumber = gdm.data( selectedPaths[index] ).group_number;
                                            updateSelectedGroup(selectedPaths, groupNumber);
                                        }
                                    }
                                }
                            ]
                        },
                        
                        ActionItem
                        {
                            id: relink
                            imageSource: "images/menu/ic_relink.png"
                            title: qsTr("Move") + Retranslate.onLanguageChanged
                            enabled: link.enabled
                            
                            onTriggered: {
                                console.log("UserEvent: RelinkNarrations");
                                
                                var groupNumber = gdm.data( gdm.last() ).group_number+1; // to guarantee we'll get a unique new group number
                                updateSelectedGroup( listView.selectionList(), groupNumber );
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
                    
                    function onDecorated(data)
                    {
                        gdm.clear();
                        gdm.insertList(data);
                        
                        listView.visible = !gdm.isEmpty();
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
                            persist.showToast( qsTr("Related narrations moved!"), relink.imageSource.toString()  );
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
                            
                            Container
                            {
                                horizontalAlignment: HorizontalAlignment.Fill
                                leftPadding: 10; rightPadding: 10; bottomPadding: 10
                                
                                Label {
                                    id: bodyLabel
                                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                                    multiline: true
                                    text: ListItemData.body+" ("+ListItemData.name+" #"+ListItemData.hadith_number+")"
                                }
                                
                                Divider {
                                    topMargin: 0; bottomMargin: 0;
                                }
                            }
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