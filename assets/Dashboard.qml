import bb.cascades 1.3

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