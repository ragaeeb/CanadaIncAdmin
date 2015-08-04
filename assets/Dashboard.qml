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
                backgroundColor: Color.Green
                ActionBar.placement: ActionBarPlacement.Signature
                imageSource: "images/menu/ic_upload_local.png"
                title: qsTr("Upload Quran10") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    var yes = persist.showBlockingDialog( qsTr("Upload"), qsTr("This will completely replace the remote database with your local one. Are you sure you want to do this?") );
                    
                    if (yes) {
                        app.compressIlmDatabase();
                    }
                }
            },
            
            ActionItem
            {
                id: reorder
                imageSource: "images/menu/ic_top.png"
                title: qsTr("Reorder") + Retranslate.onLanguageChanged
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllIds) {
                        tafsirHelper.setIndexAsId(reorder, data);
                    } else if (id == QueryId.UpdateIdWithIndex) {
                        persist.showToast( qsTr("Successfully reordered!"), "images/menu/ic_top.png" );
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: Reorder");
                    tafsirHelper.fetchAllIds(reorder, "locations");
                    tafsirHelper.fetchAllIds(reorder, "individuals");
                    tafsirHelper.fetchAllIds(reorder, "mentions");
                }
            },
            
            ActionItem
            {
                id: reorderSuites
                imageSource: "images/menu/ic_top.png"
                title: qsTr("Reorder Suites") + Retranslate.onLanguageChanged
                property variant intersection
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchSuitePageIntersection)
                    {
                        intersection = data;
                        tafsirHelper.fetchAllIds(reorderSuites, "suites");
                    } else if (id == QueryId.FetchAllIds) {
                        tafsirHelper.setIndexAsId(reorderSuites, data, intersection);
                    } else if (id == QueryId.UpdateIdWithIndex) {
                        persist.showToast( qsTr("Successfully reordered suite pages!"), "images/menu/ic_top.png" );
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: ReorderSuites")
                    tafsirHelper.fetchSuitePageIntersection(reorderSuites, "arabic");
                }
            },
            
            ActionItem
            {
                ActionBar.placement: ActionBarPlacement.OnBar
                imageSource: "images/menu/ic_copy.png"
                title: qsTr("Replicate") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    app.replicateEnglishDatabase();
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
        
        function onReady() {
            reporter.initPage(dashboard);
        }
        
        onCreationCompleted: {
            app.lazyInitComplete.connect(onReady);
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}