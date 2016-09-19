import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: narrationPage
    function cleanUp() {}
    property variant narrationId

    onNarrationIdChanged: {
        if (narrationId) {
            sunnah.fetchNarration(narrationPage, narrationId);
            sunnah.fetchGroupsForNarration(narrationPage, narrationId);
            sunnah.fetchExplanationsFor(narrationPage, narrationId);
        }
    }
    
    actions: [
        ActionItem
        {
            imageSource: "images/common/ic_copy.png"
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.Signature
            
            onTriggered: {
                console.log("UserEvent: CopyHadith");
                persist.copyToClipboard( adm.value(0).body+"\n\n"+tb.title);
            }
        }
    ]
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchNarration && data.length > 0)
        {
            var hadith = data[0];
            tb.title = "%1 %2".arg(hadith.name).arg(hadith.hadith_number);
            adm.append(data);
        } else if (id == QueryId.FetchGroupsForNarration || id == QueryId.FetchExplanationsFor) {
            adm.append(data);
        } else if (id == QueryId.SearchNarrations && data.length > 0) {
            var c = Qt.launch("NarrationPickerPage.qml");
            c.narrationList.onDataLoaded(QueryId.SearchNarrations, data);
        } else if (id == QueryId.UnlinkNarrationsFromSimilar) {
            persist.showToast( qsTr("Unlinked from group"), "images/menu/ic_unlink.png" );
        }
    }
    
    titleBar: TitleBar
    {
        id: tb
        
        acceptAction: ActionItem {
            title: narrationId ? narrationId.toString() : ""
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        ListView
        {
            id: listView
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function itemType(data, indexPath)
            {
                if (data.hadith_number) {
                    return "narration";
                } else if (data.title) {
                    return "suitePage";
                } else {
                    return "group"
                }
            }
            
            function unlinkFromGroup(ListItem, ListItemData)
            {
                sunnah.unlinkNarrationFromSimilar(narrationPage, [ListItemData.id]);
                ListItem.view.dataModel.removeAt(ListItem.indexPath[0]);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "narration"
                    
                    NarrationListItem {}
                },
                
                ListItemComponent
                {
                    type: "suitePage"
                    
                    StandardListItem
                    {
                        title: ListItemData.author
                        description: ListItemData.heading && ListItemData.heading.length > 0 ? ListItemData.heading : ListItemData.title
                        imageSource: "images/list/ic_tafsir.png"
                    }
                },
                
                ListItemComponent
                {
                    type: "group"
                    
                    StandardListItem
                    {
                        id: sli
                        imageSource: "images/list/ic_folder.png"
                        title: qsTr("Group: %1").arg(ListItemData.group_number)
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_unlink.png"
                                    title: qsTr("Unlink") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: UnlinkNarrationFromGroup");
                                        sli.ListItem.view.unlinkFromGroup(sli.ListItem, ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
            
            onTriggered: {
                var element = dataModel.data(indexPath);
                
                if (element.title)
                {
                    var c = Qt.launch("CreateSuitePage.qml");
                    c.suitePageId = element.id;
                } else if (!element.body) {
                    sunnah.fetchNarrationsInGroup(narrationPage, element.group_number);
                }
            }
        }
    }
}