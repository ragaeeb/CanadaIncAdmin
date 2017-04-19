import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    TagPickerPage
    {
        id: tagPicker
        
        onTotalLoaded: {
            navigationPane.parent.unreadContentCount = size;
        }
        
        onPicked: {            
            var page = Qt.launch("TafsirContentsPage.qml");
            page.title = picked.name;
            page.tagId = picked.id;
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
    }
}