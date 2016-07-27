import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane

    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    TafsirPickerPage
    {
        id: tafsirPicker
        
        function onDataLoaded(id, data)
        {
            if (id == QueryId.TagSuites) {
                persist.showToast( qsTr("Suites tagged!"), "images/toast/ic_add_tag.png" );
            }
        }
        
        function onFinished(tag, data)
        {
            if (tag.length > 0) {
                ilmHelper.tagSuites(tafsirPicker, data, tag);
            }
        }
        
        onTafsirPicked: {
            if (data.length > 1) {
                var all = [];
                
                for (var i = data.length-1; i >= 0; i--) {
                    all.push(data[i].id);
                }
                
                persist.showPrompt( tafsirPicker, qsTr("Enter tag"), qsTr("You can use this tag to categorize the articles."), "salat10", qsTr("Tag..."), 30, "onFinished", all );
            } else {
                if (data[0].suite_page_id)
                {
                    definition.source = "CreateSuitePage.qml";
                    var page = definition.createObject();
                    page.suitePageId = data[0].suite_page_id;
                    navigationPane.push(page);
                } else {
                    definition.source = "TafsirContentsPage.qml";
                    var page = definition.createObject();
                    page.title = data[0].title;
                    page.suiteId = data[0].id;
                    navigationPane.push(page);
                }
            }
        }
        
        actions: [
            ActionItem
            {
                imageSource: "images/menu/ic_search_action.png"
                title: qsTr("Find Duplicates") + Retranslate.onLanguageChanged
                ActionBar.placement: ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: FindDuplicateSuites");
                    tafsirPicker.busyControl = true;
                    tafsirHelper.findDuplicateSuites(tafsirPicker.suiteList, tafsirPicker.filter);
                }
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.Search
                    }
                ]
            }
        ]
        
        onCreationCompleted: {
            reload();
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}