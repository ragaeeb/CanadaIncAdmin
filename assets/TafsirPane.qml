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
            var page = Qt.launch("TafsirContentsPage.qml");
            page.title = data[0].title;
            page.suiteId = data[0].id;

            if (data[0].suite_page_id != null && searchField.text.trim().length > 0)
            {
                var searchData = {'suitePageId': data[0].suite_page_id};
                
                if (tafsirPicker.filter == "body") {
                    searchData.query = searchField.text.trim();
                }

                page.searchData = searchData;
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
}