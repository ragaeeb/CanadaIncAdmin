import bb.cascades 1.3
import bb.cascades.pickers 1.0
import com.canadainc.data 1.0

Page
{
    id: settingsPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function cleanUp()
    {
        admin.uploadProgress.disconnect(progressIndicator.onNetworkProgressChanged);
        admin.compressing.disconnect(progressIndicator.onCompressing);
        admin.compressed.disconnect(progressIndicator.onCompressed);
        admin.compressProgress.disconnect(progressIndicator.onCompressProgress);
    }
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ScrollView
        {  
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            scrollRole: ScrollRole.Main
            
            Container
            {
                leftPadding: 10
                topPadding: 10
                rightPadding: 10
                bottomPadding: 10
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                PersistDropDown
                {
                    title: qsTr("Ilm Language") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    key: "translation"
                    
                    Option {
                        text: qsTr("Arabic") + Retranslate.onLanguageChanged
                        value: "arabic"
                    }
                    
                    Option {
                        text: qsTr("English") + Retranslate.onLanguageChanged
                        value: "english"
                    }
                    
                    onValueChanged: {
                        if (diff)
                        {
                            var confirm = persist.showBlockingToast( "Download", "Database doesn't exist, download it?" );
                            
                            if (confirm) {
                                
                            }
                        }
                    }
                }
                
                ProgressIndicator
                {
                    id: progressIndicator
                    horizontalAlignment: HorizontalAlignment.Center
                    verticalAlignment: VerticalAlignment.Center
                    value: 0
                    fromValue: 0
                    toValue: 100
                    opacity: value == 0 ? 0 : value/100
                    state: ProgressIndicatorState.Progress
                    topMargin: 0; bottomMargin: 0; leftMargin: 0; rightMargin: 0;
                    
                    function onNetworkProgressChanged(cookie, current, total)
                    {
                        value = current;
                        toValue = total;
                        
                        infoText.text = qsTr("Uploading %1/%2...").arg( current.toString() ).arg( total.toString() );
                    }
                    
                    function onCompressed(success)
                    {
                        if (success) {
                            infoText.text = qsTr("Uploading...");
                        } else {
                            infoText.text = qsTr("Error...");
                        }

                        busy.delegateActive = false;
                    }
                    
                    function onCompressProgress(current, total)
                    {
                        value = current;
                        toValue = total;

                        infoText.text = qsTr("Compressing %1/%2...").arg( current.toString() ).arg( total.toString() );
                    }
                    
                    function onCompressing()
                    {
                        infoText.text = qsTr("Compressing...");
                        infoText.content.flags = TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff;
                        busy.delegateActive = true;
                    }
                    
                    onCreationCompleted: {
                        admin.uploadProgress.connect(onNetworkProgressChanged);
                        admin.compressing.connect(onCompressing);
                        admin.compressed.connect(onCompressed);
                        admin.compressProgress.connect(onCompressProgress);
                    }
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/uploading_local.png"
        }
    }
    
    onCreationCompleted: {
        admin.initPage(settingsPage);
    }
}