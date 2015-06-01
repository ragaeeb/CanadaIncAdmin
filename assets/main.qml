import bb.cascades 1.3

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
        id: quotesTab
        title: qsTr("Quotes") + Retranslate.onLanguageChanged
        description: qsTr("Sayings of the Salaf") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_quotes.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        newContentAvailable: admin.pendingUpdates
        
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
        newContentAvailable: admin.pendingUpdates
        
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
        newContentAvailable: admin.pendingUpdates
        
        onTriggered: {
            console.log("UserEvent: RijaalTab");
        }
        
        delegate: Delegate {
            source: "IndividualsPane.qml"
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}