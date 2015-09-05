import bb.cascades 1.3
import bb.system 1.2

TabbedPane
{
    id: root
    
    Menu.definition: MenuDefinition
    {
        actions: [
            ActionItem
            {
                id: toggler
                imageSource: "images/menu/ic_validate_location.png"
                
                onTriggered:
                {
                    console.log("UserEvent: SettingsPage");

                    var current = persist.getValueFor("translation");
                    
                    if (!current) {
                        current = "english";
                    }
                                        
                    persist.saveValueFor("translation", current == "english" ? "arabic" : "english");
                }
                
                function onSettingChanged(newValue, key)
                {
                    if (!newValue) {
                        newValue = "english";
                    }
                    
                    if (newValue == "english") {
                        title = qsTr("Arabic");
                        imageSource = "images/menu/ic_validate_location.png";
                    } else {
                        title = qsTr("English");
                        imageSource = "images/menu/ic_switch_to_english.png";
                    }
                }
                
                onCreationCompleted: {
                    persist.registerForSetting(toggler, "translation");
                }
            }
        ]
        
        settingsAction: SettingsActionItem
        {
            id: settingsActionItem
            imageSource: "images/menu/ic_settings.png"
            
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
        imageSource: "images/tabs/ic_dash.png"
        
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
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(spd.onReady);
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
                
                update();
            }
            
            function onCompressing()
            {
                statusDetails = qsTr("Compressing...");
                showOrUpdate();
            }
            
            function showOrUpdate()
            {
                if (!showing) {
                    show();
                    showing = true;
                } else {
                    update();
                }
            }
            
            function onTransferring(cookie, current, total)
            {
                progress = ((current*1.0)/total)*100;
                statusMessage = "Progress: %1%".arg(progress);
                
                showOrUpdate();
            }
            
            function dismiss()
            {
                if (showing)
                {
                    showing = false;
                    cancel();
                }
            }
            
            function onReady()
            {
                app.compressing.connect(onCompressing);
                app.compressed.connect(onCompressed);
                app.compressProgress.connect(onCompressProgress);
                app.requestComplete.connect(dismiss);
                app.transferProgress.connect(onTransferring);
            }
        }
    ]
}