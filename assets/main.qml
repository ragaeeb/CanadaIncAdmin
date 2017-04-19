import bb.cascades 1.3
import bb.system 1.2

TabbedPane
{
    id: root
    
    Menu.definition: MenuDefinition
    {
        helpAction: HelpActionItem
        {
            imageSource: "images/menu/ic_add_book.png"
            title: qsTr("Collections") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: Collections");
                var ipp = Qt.launch("TafsirPickerPage.qml");
                ipp.autoFocus = true;
            }
        }
        
        actions: [
            /*ActionItem
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
            },*/
            
            ActionItem
            {
                id: quranLookup
                imageSource: "images/list/ic_tafsir_ayat.png"
                title: qsTr("Quran Lookup") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    var x = Qt.launch("QuranSurahPicker.qml");
                    x.focus();
                }
            },
            
            ActionItem
            {
                id: searchHadith
                imageSource: "images/dropdown/ic_any_narrations.png"
                title: qsTr("Ahadeeth") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    Qt.launch("NarrationPickerPage.qml");
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
                launch("SettingsPage.qml");
            }
        }
    }
    
    function popToRoot(page)
    {
        var ap = root.activePane;
        
        while (ap.top != page) {
            ap.pop();
        }
    }
    
    function launch(qml)
    {
        definition.source = qml;
        var page = definition.createObject();
        root.activePane.push(page);
        
        return page;
    }
    
    onActivePaneChanged: {
        Qt.navigationPane = activePane;
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
        id: tags
        title: qsTr("Tags") + Retranslate.onLanguageChanged
        description: qsTr("Keywords") + Retranslate.onLanguageChanged
        imageSource: "images/list/ic_tag.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: TagTab");
        }
        
        delegate: Delegate {
            source: "TagPane.qml"
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
    
    Tab
    {
        id: questionsTab
        title: qsTr("Questions") + Retranslate.onLanguageChanged
        description: qsTr("Quiz") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_questions.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: QuestionsTab");
        }
        
        delegate: Delegate {
            source: "QuestionsPane.qml"
        }
    }
    
    Tab
    {
        id: masjidsTab
        title: qsTr("Centers") + Retranslate.onLanguageChanged
        description: qsTr("Masjids") + Retranslate.onLanguageChanged
        imageSource: "images/tabs/ic_centers.png"
        delegateActivationPolicy: TabDelegateActivationPolicy.ActivateWhenSelected
        
        onTriggered: {
            console.log("UserEvent: CentersTab");
        }
        
        delegate: Delegate {
            source: "MasjidsPane.qml"
        }
    }
    
    onCreationCompleted: {
        app.lazyInitComplete.connect(spd.onReady);
        Qt.launch = launch;
        Qt.popToRoot = popToRoot;
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

                activePane.process();
            }
        }
    ]
}