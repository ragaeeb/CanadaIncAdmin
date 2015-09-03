import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: questionsPage
    property variant suitePageId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSuitePageIdChanged: {
        if (suitePageId)
        {
        }
    }
    
    function cleanUp() {}
    
    function popToRoot()
    {
        while (navigationPane.top != narrationsPage) {
            navigationPane.pop();
        }
    }
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(questionsPage, listView);
        adm.append("LJK");
        adm.append("LJK33");
        adm.append("LJK44");
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ListView
        {
            id: listView
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function onDataLoaded(id, data)
            {
                
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    Container
                    {
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        
                        Header {
                            title: "Questions"
                            horizontalAlignment: HorizontalAlignment.Fill
                        }
                        
                        TextField {
                            id: standardBody
                            hintText: qsTr("Standard Body") + Retranslate.onLanguageChanged
                        }
                        
                        TextField {
                            id: orderedBody
                            hintText: qsTr("Ordered Body") + Retranslate.onLanguageChanged
                        }
                        
                        TextField {
                            id: countBody
                            hintText: qsTr("Count Body") + Retranslate.onLanguageChanged
                        }
                        
                        TextField {
                            id: beforeBody
                            hintText: qsTr("Before Body") + Retranslate.onLanguageChanged
                        }
                        
                        TextField {
                            id: afterBody
                            hintText: qsTr("After Body") + Retranslate.onLanguageChanged
                        }
                    }
                }
            ]
        }
    }
}