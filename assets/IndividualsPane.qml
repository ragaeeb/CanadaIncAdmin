import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function popToRoot()
    {
        while (navigationPane.top != individualPicker) {
            navigationPane.pop();
        }
    }
    
    function onEdit(id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion)
    {
        tafsirHelper.editIndividual(navigationPane, id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion);
        
        var obj = individualPicker.createObject(id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion);
        individualPicker.model.replace(individualPicker.editIndexPath[0], obj);

        popToRoot();
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.EditIndividual) {
            persist.showToast( qsTr("Successfully edited individual"), "images/menu/ic_edit_rijaal.png" );
            individualPicker.refresh();
        } else if (id == QueryId.RemoveIndividual) {
            persist.showToast( qsTr("Successfully deleted individual!"), "images/menu/ic_delete_individual.png" );
            individualPicker.refresh();
        } else if (id == QueryId.ReplaceIndividual) {
            persist.showToast( qsTr("Successfully replaced individual!"), "images/menu/ic_replace_individual.png" );
            individualPicker.performSearch();
        } else if (id == QueryId.PortIndividuals) {
            persist.showToast( qsTr("Successfully ported individuals!"), "images/menu/ic_replace_individual.png" );
            individualPicker.busyControl.delegateActive = false;
        }
    }
    
    function getSelectedIds()
    {
        var all = individualPicker.pickerList.selectionList();
        var ids = [];
        
        for (var i = all.length-1; i >= 0; i--) {
            ids.push( individualPicker.model.data( all[i] ).id );
        }
        
        return ids;
    }
    
    IndividualPickerPage
    {
        id: individualPicker
        property variant toReplaceId
        property variant editIndexPath
        
        actions: [
            ActionItem {
                id: portAction
                imageSource: "images/menu/ic_preview.png"
                title: qsTr("Port") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.InOverflow
                
                onTriggered: {
                    console.log("UserEvent: Port");
                    individualPicker.busyControl.delegateActive = true;
                    tafsirHelper.portIndividuals(navigationPane, "arabic");
                }
            }
        ]
        
        onContentLoaded: {
            navigationPane.parent.unreadContentCount = size;
        }
        
        function edit(ListItem)
        {
            editIndexPath = ListItem.indexPath;
            definition.source = "CreateIndividualPage.qml";
            var page = definition.createObject();
            page.individualId = ListItem.data.id;
            page.createIndividual.connect(onEdit);
            
            navigationPane.push(page);
        }
        
        function removeItem(ListItem)
        {
            individualPicker.busyControl.delegateActive = true;
            tafsirHelper.removeIndividual(navigationPane, ListItem.data.id);
            individualPicker.model.removeAt(ListItem.indexPath[0]);
        }
        
        function onActualPicked(actualId)
        {
            if (actualId != toReplaceId)
            {
                individualPicker.busyControl.delegateActive = true;
                tafsirHelper.replaceIndividual(navigationPane, toReplaceId, actualId);
            } else {
                persist.showToast( qsTr("The source and replacement individuals cannot be the same!"), "images/toast/ic_duplicate_replace.png" );
            }
            
            popToRoot();
        }
        
        function replace(ListItemData)
        {
            toReplaceId = ListItemData.id;
            definition.source = "IndividualPickerPage.qml";
            var ipp = definition.createObject();
            ipp.picked.connect(onActualPicked);
            
            navigationPane.push(ipp);
        }
        
        pickerList.listItemComponents: [
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
                            subtitle: sli.description

                            ActionItem
                            {
                                imageSource: "images/menu/ic_copy.png"
                                title: qsTr("Copy") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: CopyIndividual");
                                    persist.copyToClipboard(sli.title);
                                }
                            }
                            
                            ActionItem
                            {
                                imageSource: "images/menu/ic_edit_rijaal.png"
                                title: qsTr("Edit") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: EditIndividual");
                                    sli.ListItem.view.pickerPage.edit(sli.ListItem);
                                }
                            }
                            
                            ActionItem
                            {
                                imageSource: "images/menu/ic_preview.png"
                                title: qsTr("Open in Quran10") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: OpenQuran10");
                                    persist.invoke( "com.canadainc.Quran10.bio.previewer", "", "", "", ListItemData.id.toString() );
                                }
                            }
                            
                            ActionItem
                            {
                                imageSource: "images/menu/ic_replace_individual.png"
                                title: qsTr("Replace") + Retranslate.onLanguageChanged
                                
                                onTriggered: {
                                    console.log("UserEvent: ReplaceIndividual");
                                    sli.ListItem.view.pickerPage.replace(ListItemData);
                                }
                            }
                            
                            DeleteActionItem
                            {
                                imageSource: "images/menu/ic_delete_individual.png"
                                
                                onTriggered: {
                                    console.log("UserEvent: DeleteIndividual");
                                    sli.ListItem.view.pickerPage.removeItem(sli.ListItem);
                                }
                            }
                        }
                    ]
                }
            }
        ]
        
        onPicked: {
            definition.source = "ProfilePage.qml";
            var page = definition.createObject();
            page.individualId = individualId;
            
            navigationPane.push(page);
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}