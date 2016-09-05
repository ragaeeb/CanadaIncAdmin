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
        
        onTafsirPicked: {            
            definition.source = "TafsirContentsPage.qml";
            var page = definition.createObject();
            page.title = data[0].title;
            page.suiteId = data[0].id;
            
            if (data[0].suite_page_id && searchField.text.length > 0) {
                page.searchData = {'query': searchField.text, 'suitePageId': data[0].suite_page_id};
            }
            
            navigationPane.push(page);
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