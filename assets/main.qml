import bb.cascades 1.3
import bb.system 1.2

TabbedPane
{
    id: root
    
    Menu.definition: MenuDefinition
    {
        settingsAction: SettingsActionItem
        {
            id: settingsActionItem
            
            onTriggered:
            {
                console.log("UserEvent: SettingsPage");
                
                definition.source = "SettingsPage.qml"
                var settingsPage = definition.createObject();
                root.activePane.push(settingsPage);
            }
        }
    }
    
    Tab
    {
        title: "Dashboard"
        description: "Admin Dashboard"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: Dashboard");
        }
        
        delegate: Delegate {
            source: "Dashboard.qml"
        }
    }
    
    Tab
    {
        id: quotesTab
        title: qsTr("Quotes") + Retranslate.onLanguageChanged
        description: qsTr("Sayings of the Salaf") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_quotes.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: Quotes");
        }
        
        delegate: Delegate {
            source: "QuotesPane.qml"
        }
    }
    
    Tab
    {
        id: tafsirTab
        title: qsTr("Tafsir") + Retranslate.onLanguageChanged
        description: qsTr("Suites") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_tafsir.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: TafsirTab");
        }
        
        delegate: Delegate {
            source: "TafsirPane.qml"
        }
    }
    
    Tab
    {
        id: rijaalTab
        title: qsTr("Rijaal") + Retranslate.onLanguageChanged
        description: qsTr("Individuals") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_rijaal.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: RijaalTab");
        }
        
        delegate: Delegate {
            source: "IndividualsPane.qml"
        }
    }
    
    function onReady()
    {
        app.transferProgress.connect(spd.onTransferring);
        app.requestComplete.connect(spd.dismiss);
        app.compressing.disconnect(spd.onCompressing);
        app.compressed.disconnect(spd.onCompressed);
        app.compressProgress.disconnect(spd.onCompressProgress);
    }
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(onReady);
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        },
        
        SystemProgressDialog
        {
            id: spd
            title: "Transferring..."
            body: "Transfer in progress..."
            cancelButton.label: ""
            confirmButton.label: "OK"
            emoticonsEnabled: false
            icon: "asset:///images/progress/loading_suites.png"
            property bool showing: false
            
            function onCompressProgress(current, total) {
                onTransferring("", current, total);
            }
            
            function onCompressed(success)
            {
                if (success) {
                    statusDetails = qsTr("Uploading...");
                } else {
                    statusDetails = qsTr("Error...");
                }
            }
            
            function onCompressing() {
                statusDetails = qsTr("Compressing...");
            }
            
            function onTransferring(cookie, current, total)
            {
                progress = ((current*1.0)/total)*100;
                statusMessage = "Progress: %1%".arg(progress);
                
                if (!showing) {
                    show();
                    showing = true;
                } else {
                    update();
                }
            }
            
            function dismiss()
            {
                if (showing)
                {
                    showing = false;
                    cancel();
                }
            }
        }
    ]
}