import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: questionsPage
    property variant suitePageId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onSuitePageIdChanged: {
        if (suitePageId) {
            ilmTest.fetchQuestionsForSuitePage(listView, suitePageId);
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
                adm.clear();
                adm.append(data);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        imageSource: ListItemData.source_id ? "images/list/ic_question_alias.png" : "images/list/ic_question.png"
                        status: ListItemData.difficulty ? ListItemData.difficulty.toString() : ""
                        title: ListItemData.standard_body ? ListItemData.standard_body : ""
                        description: ListItemData.count_body ? ListItemData.count_body : ""
                    }
                }
            ]
        }
    }
    
    attachedObjects: [
        Dialog
        {
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                Header {
                    title: ListItemData.id ? ListItemData.id.toString() : ""
                    horizontalAlignment: HorizontalAlignment.Fill
                }
                

            }
        }
    ]
}