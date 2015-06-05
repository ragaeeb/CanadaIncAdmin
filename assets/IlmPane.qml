import bb.cascades 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane

    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function onCreate(id, author, translator, explainer, title, description, reference)
    {
        tafsirHelper.addTafsir(navigationPane, author, translator, explainer, title, description, reference);
        
        while (navigationPane.top != tafsirPicker) {
            navigationPane.pop();
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.AddTafsir)
        {
            persist.showToast( qsTr("Tafsir added!"), "images/menu/ic_add_suite.png" );
            tafsirPicker.reload();
        }
    }
    
    TafsirPickerPage
    {
        id: tafsirPicker
        
        onTafsirPicked: {
            definition.source = "TafsirContentsPage.qml";
            var page = definition.createObject();
            page.title = data[0].title;
            page.suiteId = data[0].id;
            
            navigationPane.push(page);
        }
        
        actions: [
            ActionItem
            {
                imageSource: "images/menu/ic_add_suite.png"
                title: qsTr("Add") + Retranslate.onLanguageChanged
                ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
                
                onTriggered: {
                    console.log("UserEvent: NewSuite");
                    definition.source = "CreateTafsirPage.qml";
                    var page = definition.createObject();
                    page.createTafsir.connect(onCreate);
                    
                    navigationPane.push(page);
                }
                
                shortcuts: [
                    SystemShortcut {
                        type: SystemShortcuts.CreateNew
                    }
                ]
            },
            
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