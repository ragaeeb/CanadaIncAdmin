import bb.cascades 1.3
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function reload()
    {
        busy.delegateActive = true;
        salat.fetchAllCenters(listView, tftk.textField.text.trim());
    }
    
    function clearAndReload()
    {
        adm.clear();
        reload();
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(masjidPickerPage, listView, true);
        reload();
        app.textualChange.connect(clearAndReload);
    }
    
    Page
    {
        id: masjidPickerPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        actions: [
            ActionItem
            {
                id: addAction
                imageSource: "images/menu/ic_add_center.png"
                title: qsTr("Add") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
                
                function onCreate(id, name, website, location)
                {
                    var x = salat.addCenter(name, website, location);
                    
                    adm.insert(0,x); // add the latest value to avoid refreshing entire list
                    listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    navigationPane.parent.unreadContentCount += 1;
                    
                    persist.showToast( qsTr("Center added!"), addAction.imageSource.toString() );
                    
                    Qt.popToRoot(masjidPickerPage);
                    
                    refresh();
                }
                
                onTriggered: {
                    var page = Qt.launch("CreateCenterPage.qml");
                    page.createCenter.connect(onCreate);
                }
            }
        ]
        
        titleBar: TitleBar
        {
            kind: TitleBarKind.TextField
            kindProperties: TextFieldTitleBarKindProperties
            {
                id: tftk
                textField.hintText: qsTr("Enter name of center to search...") + Retranslate.onLanguageChanged
                textField.input.submitKey: SubmitKey.Submit
                textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                textField.onTextChanging: {
                    clearAndReload();
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
                    property variant editIndexPath
                    scrollRole: ScrollRole.Main
                    
                    dataModel: ArrayDataModel {
                        id: adm
                    }
                    
                    function onDataLoaded(id, data)
                    {
                        if (id == QueryId.FetchAllCenters && data.length > 0)
                        {
                            adm.append(data);
                            navigationPane.parent.unreadContentCount = data.length;
                        } else if (id == QueryId.EditCenter) {
                            persist.showToast( qsTr("Center updated!"), "images/menu/ic_edit_center.png" );
                        }
                        
                        refresh();
                    }
                    
                    listItemComponents: [
                        ListItemComponent
                        {
                            StandardListItem
                            {
                                id: rootItem
                                description: ListItemData.website
                                imageSource: "images/list/ic_masjid.png"
                                title: ListItemData.name
                            }
                        }
                    ]
                    
                    function onEdit(id, name, website, location)
                    {
                        busy.delegateActive = true;
                        salat.editCenter(listView, id, name, website, location);
                        
                        var current = dataModel.data(editIndexPath);
                        current["name"] = name;
                        current["website"] = website;
                        current["location"] = location;
                        
                        dataModel.replace(editIndexPath[0], current);
                        
                        Qt.popToRoot(masjidPickerPage);
                    }
                    
                    onTriggered: {
                        console.log("UserEvent: OpenCenter");
                        var d = dataModel.data(indexPath);
                        
                        var page = Qt.launch("CreateCenterPage.qml");
                        page.centerId = d.id;
                        editIndexPath = indexPath;
                        
                        page.createCenter.connect(onEdit);
                    }
                }
            }
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_centers.png"
                labelText: qsTr("No centers matched your search criteria. Please try a different search term.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: NoCentersTapped");
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_centers.png"
            }
        }
    }
    
    function refresh()
    {
        busy.delegateActive = false;
        listView.visible = !adm.isEmpty();
        noElements.delegateActive = !listView.visible;
    }
}