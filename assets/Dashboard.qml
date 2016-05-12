import bb.cascades 1.3
import bb.system 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    Page
    {
        id: dashboard
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        actions: [
            ActionItem
            {
                id: upload
                ActionBar.placement: ActionBarPlacement.Signature
                imageSource: "images/menu/ic_upload_local.png"
                title: qsTr("Upload") + Retranslate.onLanguageChanged

                function onFinished(confirmed, notifyClients)
                {
                    if (confirmed) {
                        app.compressIlmDatabase(notifyClients);
                    }
                }
                
                onTriggered: {
                    var yes = persist.showDialog( upload, qsTr("Upload"), qsTr("This will completely replace the remote database with your local one. Are you sure you want to do this?"), qsTr("Yes"), qsTr("No"), qsTr("Notify Consumers?"), false );
                }
            },
            
            ActionItem
            {
                id: reorder
                imageSource: "images/menu/ic_reorder.png"
                title: qsTr("XX") + Retranslate.onLanguageChanged
                
                function onDataLoaded(id, data)
                {
                    if (id == -4) {
                        sql.setIndexAsId(reorder, data);
                    } else if (id == -6) {
                        persist.showToast( qsTr("Successfully reordered!"), "images/menu/ic_top.png" );
                    }
                }
                
                onTriggered: {
                    app.createContacts();
                    persist.showToast("DONE!");
                    return;
                    console.log("UserEvent: Reorder");
                    sql.fetchAllIds(reorder, "locations");
                    sql.fetchAllIds(reorder, "individuals");
                    sql.fetchAllIds(reorder, "mentions");
                    //sql.fetchAllIds(reorder, "answers");
                    sql.fetchAllIds(reorder, "choices");
                    //sql.fetchAllIds(reorder, "questions");
                }
            },
            
            ActionItem
            {
                id: reorderSuites
                imageSource: "images/menu/ic_reorder_suites.png"
                title: qsTr("Reorder Suites") + Retranslate.onLanguageChanged
                property variant intersection
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchSuitePageIntersection)
                    {
                        intersection = data;
                        sql.fetchAllIds(reorderSuites, "suites");
                    } else if (id == QueryId.FetchAllIds) {
                        sql.setIndexAsId(reorderSuites, data, intersection);
                    } else if (id == QueryId.UpdateIdWithIndex) {
                        persist.showToast( qsTr("Successfully reordered suite pages!"), "images/menu/ic_top.png" );
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: ReorderSuites")
                    tafsirHelper.fetchSuitePageIntersection(reorderSuites, "arabic");
                }
            },
            
            InvokeActionItem
            {
                imageSource: "images/menu/ic_share_db.png"
                title: qsTr("Share Database")
                ActionBar.placement: ActionBarPlacement.OnBar
                
                query {
                    mimeType: "application/x-sqlite3"
                    uri: "file://%1/%2.db".arg( persist.homePath() ).arg( app.databasePath() )
                    fileTransferMode: FileTransferMode.Link
                    invokeActionId: "bb.action.SHARE"
                    invokerIncluded: false
                }
                
                onTriggered: {
                    query.updateQuery();
                }
            }
        ]
    }
    
    function process()
    {
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}