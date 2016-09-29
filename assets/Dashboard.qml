import bb.cascades 1.3
import bb.system 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function onUserFound(response)
    {
        if (response.result == "200 OK")
        {
            if (response.message) {
                persist.showToast(response.message, "images/menu/ic_remove_parent.png");
            } else if (response.user_id) {
                scrollView.visible = true;
                adm.clear();
                internal.checked = response.internal == "1";
                
                var result = [];
                var registered = offloader.diffSecs(response.registered_on);

                if (registered < 3600) { // less than an hour ago: 60s/min * 60mins/hr
                    result.push( qsTr("Registered %n mins ago", "", registered/60) );
                } else if (registered < 60*60*24) {
                    result.push( qsTr("Registered %n hours ago", "", registered/3600) );
                } else {
                    result.push( qsTr("Registered %n days ago", "", registered/(3600*24)) );
                }
                
                result.push( qsTr("OS Version: %1").arg(response.os_version) );
                result.push( qsTr("Device Model: %1").arg(response.model_name) );
                result.push( qsTr("Device Locale: %1").arg(response.locale) );
                result.push( qsTr("NodeName: %1").arg(response.node_name) );
                result.push( qsTr("Payment: %1").arg(response.payment) );
                result.push( qsTr("Service Type: %1").arg(response.service_type) );

                if (response.city) {
                    result.push( qsTr("City: %1").arg(response.city) );
                }
                
                if (response.region) {
                    result.push( qsTr("Region: %1").arg(response.region) );
                }
                
                if (response.country) {
                    result.push( qsTr("Country: %1").arg(response.country) );
                }
                
                if (response.lock_screen_l1) {
                    result.push( qsTr("LockScreen1: %1").arg(response.lock_screen_l1) );
                }
                
                if (response.lock_screen_l2) {
                    result.push( qsTr("LockScreen2: %1").arg(response.lock_screen_l2) );
                }
                
                if (response.chat) {
                    result.push(response.chat);
                }
                
                if (response.apps) {
                    adm.append(response.apps);
                }
                
                if (response.addresses) {
                    adm.append(response.addresses);
                }
                
                if (response.aliases) {
                    adm.append(response.aliases);
                }
                
                body.text = result.join("\n\n");
            } else {
                persist.showToast("Unknown error: "+JSON.stringify(response), "images/menu/ic_remove_answer.png");
            }
        } else {
            persist.showToast("Error during lookup: "+JSON.stringify(response), "images/menu/ic_remove_answer.png");
        }
    }

    onCreationCompleted: {
        app.userFound.connect(onUserFound);
        Qt.navigationPane = navigationPane;
    }
    
    function searchUser()
    {
        var address = tftk.textField.text.trim();
        
        if (address.length > 0) {
            app.lookupUser(address);
        }
    }
    
    Page
    {
        id: dashboard
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar
        {
            scrollBehavior: TitleBarScrollBehavior.Sticky
            kind: TitleBarKind.TextField
            
            acceptAction: ActionItem {
                title: "LKSDF"
                onTriggered: {
                    persist.downloadApp("27845411");
                }
            }
            
            kindProperties: TextFieldTitleBarKindProperties
            {
                id: tftk
                
                textField {
                    hintText: qsTr("Enter address to search...") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    input.keyLayout: KeyLayout.Text
                    inputMode: TextFieldInputMode.Text
                    input.submitKey: SubmitKey.Search
                    input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                    
                    input.onSubmitted: {
                        searchUser();
                    }
                    
                    gestureHandlers: [
                        DoubleTapHandler {
                            onDoubleTapped: {
                                tftk.textField.text = persist.getClipboardText();
                                searchUser();
                            }
                        }
                    ]
                }
            }
        }
        
        Container
        {
            id: scrollView
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            visible: false
            
            ActivityIndicator {
                id: busy
                running: false
            }
            
            CheckBox
            {
                id: internal
                horizontalAlignment: HorizontalAlignment.Fill
                enabled: false
                text: qsTr("BlackBerry Employee")
            }
            
            Header {
                title: "Device Info"
                bottomMargin: 0
            }
            
            TextArea
            {
                id: body
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                backgroundVisible: false
                editable: false
                maxHeight: 400
                topMargin: 0; bottomMargin: 0
            }
            
            Header {
                title: "User Info"
            }
            
            ListView
            {
                id: listView
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function itemType(data, indexPath)
                {
                    if (data.address) {
                        return data.address_type ? data.address_type : data.address.indexOf("@") > 0 ? "email" : "unknown_address";
                    } else if (data.version) {
                        return "app";
                    } else if (data.user_id) {
                        return "user";
                    } else {
                        return "unknown"
                    }
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
                        type: "whatsapp"
                        
                        StandardListItem
                        {
                            title: ListItemData.address
                            description: "WhatsApp"
                            imageSource: "images/list/ic_whatsapp.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "bbm"
                        
                        StandardListItem
                        {
                            title: ListItemData.address
                            description: "BBM"
                            imageSource: "file:///usr/share/icons/ic_start_bbm_chat.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "unknown_address"
                        
                        StandardListItem
                        {
                            title: ListItemData.address
                            description: "Unknown"
                            imageSource: "images/menu/ic_help.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "known_name"
                        
                        StandardListItem
                        {
                            title: ListItemData.address
                            description: "Name"
                            imageSource: "images/list/ic_parent.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "facebook"
                        
                        StandardListItem
                        {
                            title: ListItemData.address
                            description: "Facebook"
                            imageSource: "images/list/site_facebook.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "instagram"
                        
                        StandardListItem
                        {
                            title: ListItemData.address
                            description: "Instagram"
                            imageSource: "images/list/site_instagram.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "twitter"
                        
                        StandardListItem
                        {
                            title: ListItemData.address
                            description: "Twitter"
                            imageSource: "images/list/site_twitter.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "phone"
                        
                        StandardListItem
                        {
                            title: "+"+ListItemData.address
                            description: "Phone"
                            imageSource: "images/list/ic_phone.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "email"
                        
                        StandardListItem
                        {
                            title: ListItemData.address
                            description: "Email"
                            imageSource: "images/list/ic_email.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "app"
                        
                        StandardListItem
                        {
                            title: ListItemData.name
                            description: ListItemData.version
                            imageSource: "images/menu/ic_accept_narrations.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "user"
                        
                        StandardListItem
                        {
                            title: ListItemData.user_id
                            description: "Alias"
                            imageSource: "images/list/ic_companion.png"
                        }
                    },
                    
                    ListItemComponent
                    {
                        type: "unknown"
                        
                        Divider
                        {
                        }
                    }
                ]
                
                onTriggered: {
                    var data = dataModel.data(indexPath);
                    
                    if (data.user_id) { // alias
                        app.lookupUser(data.user_id, true);
                    } else if (data.address_type == "facebook") {
                        persist.openUri("http://facebook.com/"+data.address);
                    } else if (data.address_type == "twitter") {
                        persist.openUri("http://twitter.com/"+data.address);
                    } else if (data.address_type == "instagram") {
                        persist.openUri("http://instagram.com/"+data.address);
                    } else if (data.address_type == "whatsapp" || data.address_type == "bbm") {
                        var name = "";
                        var whatsapp = [];
                        var bbm = [];

                        for (var i = 0; i < adm.size(); i++)
                        {
                            var current = adm.value(i);
                            
                            if ( current.address_type == "known_name" ) {
                                name = current.address;
                            } else if (current.address_type == "bbm") {
                                bbm.push(current.address);
                            } else if (current.address_type == "whatsapp") {
                                whatsapp.push(current.address);
                            }
                        }

                        name = persist.showBlockingPrompt( qsTr("Enter name text"), qsTr("Please enter the new name of this contact:"), name, qsTr("Enter name"), 100, true, qsTr("Submit"), qsTr("Cancel") ).trim();
                        
                        if (name.length > 0 && (whatsapp.length > 0 || bbm.length > 0)) {
                            app.createContactCard(name, whatsapp, bbm);
                            persist.showToast( qsTr("%1 added to contact list").arg(name), "images/menu/ic_accept.png" );
                        }
                    }
                }
            }
        }
        
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
                    persist.showDialog( upload, qsTr("Upload"), qsTr("This will completely replace the remote database with your local one. Are you sure you want to do this?"), qsTr("Yes"), qsTr("No"), qsTr("Notify Consumers?"), false );
                }
            },
            
            ActionItem
            {
                id: reorder
                imageSource: "images/menu/ic_reorder.png"
                title: qsTr("Reorder") + Retranslate.onLanguageChanged
                
                function onDataLoaded(id, data)
                {
                    if (id == -4) {
                        sql.setIndexAsId(reorder, data);
                    } else if (id == -6) {
                        persist.showToast( qsTr("Successfully reordered!"), "images/menu/ic_top.png" );
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: Reorder");
                    app.fetchAllIds(reorder, "locations");
                    app.fetchAllIds(reorder, "individuals");
                    app.fetchAllIds(reorder, "mentions");
                    //app.fetchAllIds(reorder, "answers");
                    app.fetchAllIds(reorder, "choices");
                    //app.fetchAllIds(reorder, "questions");
                }
            },
            
            ActionItem
            {
                id: hadith
                imageSource: "images/dropdown/ic_any_narrations.png"
                title: qsTr("Hadith Lookup") + Retranslate.onLanguageChanged
                
                shortcuts: [
                    Shortcut {
                        key: "H"
                    }
                ]
                
                onTriggered: {
                    Qt.launch("NarrationPickerPage.qml");
                }
            },
            
            ActionItem
            {
                id: tafsir
                imageSource: "images/list/ic_tafsir_ayat.png"
                title: qsTr("Quran Lookup") + Retranslate.onLanguageChanged
                
                shortcuts: [
                    Shortcut {
                        key: "Q"
                    }
                ]
                
                onTriggered: {
                    var x = Qt.launch("AyatProfilePage.qml");
                    x.focus();
                }
            },
            
            ActionItem
            {
                id: createContacts
                imageSource: "images/menu/ic_reorder.png"
                title: qsTr("Create Contacts") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    app.createContacts("/accounts/1000/shared/misc/nigeria.txt");
                    persist.showToast("DONE!");
                }
            },
            
            ActionItem
            {
                id: uploadChats
                imageSource: "images/menu/ic_reorder.png"
                title: qsTr("Upload Chats") + Retranslate.onLanguageChanged

                onTriggered: {
                    app.uploadChats();
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
            },
            
            DeleteActionItem
            {
                id: clearAll
                imageSource: "images/menu/ic_reset_search.png"
                title: qsTr("Clear") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    tftk.textField.resetText();
                    tftk.textField.requestFocus();
                }
            }
        ]
    }
    
    function process()
    {
    }
}