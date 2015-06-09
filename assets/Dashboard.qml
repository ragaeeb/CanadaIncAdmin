import bb.cascades 1.3
import bb.system 1.0

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
            
            InvokeActionItem
            {
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