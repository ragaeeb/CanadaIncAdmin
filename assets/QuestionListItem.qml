import bb.cascades 1.4

StandardListItem
{
    id: qsli
    imageSource: ListItemData.source_id ? "images/list/ic_question_alias.png" : "images/list/ic_question.png"
    status: ListItemData.difficulty ? ListItemData.difficulty.toString() : ""
    title: ListItemData.standard_body ? ListItemData.standard_body : ""
    
    contextActions: [
        ActionSet
        {
            title: qsli.title
            subtitle: qsli.status
            
            ActionItem
            {
                imageSource: "images/menu/ic_edit_link.png"
                title: qsTr("Duplicate") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: DuplicateQuestion");
                    qsli.ListItem.view.duplicateQuestion(qsli.ListItem, ListItemData);
                }
            }
            
            DeleteActionItem
            {
                imageSource: "images/menu/ic_remove_question.png"
                
                onTriggered: {
                    console.log("UserEvent: RemoveQuestion");
                    qsli.ListItem.view.removeQuestion(qsli.ListItem, ListItemData);
                }
            }
        }
    ]
}