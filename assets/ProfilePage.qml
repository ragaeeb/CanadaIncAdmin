import bb.cascades 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: bioPage
    property variant individualId
    property alias bioModel: bios.dataModel
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal individualsPicked(variant ids)
    
    function getHijriYear(y1, y2)
    {
        if (y1 > 0 && y2 > 0) {
            return qsTr("%1-%2 AH").arg(y1).arg(y2);
        } else if (y1 < 0 && y2 < 0) {
            return qsTr("%1-%2 BH").arg( Math.abs(y1) ).arg( Math.abs(y2) );
        } else if (y1 < 0 && y2 > 0) {
            return qsTr("%1 BH - %2 AH").arg( Math.abs(y1) ).arg(y2);
        } else {
            return y1 > 0 ? qsTr("%1 AH").arg(y1) : qsTr("%1 BH").arg( Math.abs(y1) );
        }
    }
    
    function launchPicker()
    {
        var p = Qt.launch("IndividualPickerPage.qml");
        ilmHelper.fetchFrequentIndividuals(p.pickerList, "relationships", "individual");
        
        return p;
    }
    
    actions: [
        ActionItem
        {
            id: addStudent
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_student.png"
            title: qsTr("Add Student") + Retranslate.onLanguageChanged
            
            function onPicked(student, name)
            {
                var result = ilmHelper.addRelation(student, individualId, 2);
                result.name = name;
                
                checkForDuplicate(result);
            }
            
            onTriggered: {
                console.log("UserEvent: AddStudent");

                var p = launchPicker();
                p.picked.connect(onPicked);
            }
        },
        
        ActionItem
        {
            id: addTeacher
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_teacher.png"
            title: qsTr("Add Teacher") + Retranslate.onLanguageChanged
            
            function onPicked(teacher, name)
            {
                var result = ilmHelper.addRelation(individualId, teacher, 2);
                result.name = name;
                
                checkForDuplicate(result);
            }
            
            onTriggered: {
                console.log("UserEvent: AddTeacher");

                var p = launchPicker();
                p.picked.connect(onPicked);
            }
        },
        
        ActionItem
        {
            id: editBio
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_edit_rijaal.png"
            title: qsTr("Edit") + Retranslate.onLanguageChanged
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Edit
                }
            ]
            
            function onEdit(id, prefix, name, kunya, displayName, hidden, birth, death, female, location, currentLocation, companion, description)
            {
                ilmHelper.editIndividual(bioPage, id, prefix, name, kunya, displayName, hidden, birth, death, female, location, currentLocation, companion, description);
                
                Qt.popToRoot(bioPage);
                reload();
            }
            
            onTriggered: {
                console.log("UserEvent: EditBio");
                
                var p = Qt.launch("CreateIndividualPage.qml")
                p.individualId = individualId;
                p.createIndividual.connect(onEdit);
            }
        },
        
        ActionItem
        {
            id: addParent
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_parent.png"
            title: qsTr("Add Parent") + Retranslate.onLanguageChanged
            
            function onPicked(parentId, name)
            {
                var result = ilmHelper.addRelation(individualId, parentId, 1);
                result.name = name;
                
                checkForDuplicate(result);
            }
            
            onTriggered: {
                console.log("UserEvent: AddParent");

                var p = launchPicker();
                p.picked.connect(onPicked);
            }
        },
        
        ActionItem
        {
            id: addSibling
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_sibling.png"
            title: qsTr("Add Sibling") + Retranslate.onLanguageChanged
            
            function onPicked(siblingId, name)
            {
                var result = ilmHelper.addRelation(individualId, siblingId, 3);
                result.name = name;
                
                checkForDuplicate(result);
            }
            
            onTriggered: {
                console.log("UserEvent: AddSibling");

                var p = launchPicker();
                p.picked.connect(onPicked);
            }
        },
        
        ActionItem
        {
            id: addChild
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_child.png"
            title: qsTr("Add Child") + Retranslate.onLanguageChanged
            
            function onPicked(child, name)
            {
                var result = ilmHelper.addRelation(child, individualId, 1);
                result.name = name;
                
                checkForDuplicate(result);
            }
            
            onTriggered: {
                console.log("UserEvent: AddChild");

                var p = launchPicker();
                p.picked.connect(onPicked);
            }
        },
        
        ActionItem
        {
            id: addSite
            imageSource: "images/menu/ic_add_site.png"
            title: qsTr("Add Website") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            enabled: individualId != undefined
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: NewSite");
                var uri = persist.showBlockingPrompt( qsTr("Enter url"), qsTr("Please enter the website address for this individual:"), "", qsTr("Enter url (ie: http://mtws.com)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Url ).trim().toLowerCase();
                
                if (uri.length > 0)
                {
                    uri = offloader.fixUri(uri);
                    
                    if ( deviceUtils.isUrl(uri) ) {
                        var x = ilmHelper.addWebsite(individualId, uri);
                        checkForDuplicate(x);
                        persist.showToast( qsTr("Website added!"), imageSource.toString() );
                    } else {
                        persist.showToast( qsTr("Invalid URL entered!"), "images/menu/ic_remove_site.png" );
                        console.log("FailedRegex", uri);
                    }
                }
            }
        },
        
        ActionItem
        {
            id: addEmail
            imageSource: "images/menu/ic_add_email.png"
            title: qsTr("Add Email") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled: individualId != undefined
            
            onTriggered: {
                console.log("UserEvent: NewEmail");
                var email = persist.showBlockingPrompt( qsTr("Enter email"), qsTr("Please enter the email address for this individual:"), "", qsTr("Enter email (ie: abc@hotmail.com)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Email ).trim().toLowerCase();
                
                if (email.length > 0)
                {
                    if ( deviceUtils.isValidEmail(email) ) {
                        var x = ilmHelper.addWebsite(individualId, email);
                        adm.append(x);
                        persist.showToast( qsTr("Email added!"), imageSource.toString() );
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    } else {
                        persist.showToast( qsTr("Invalid email entered!"), "images/menu/ic_remove_email.png" );
                        console.log("FailedRegex", email);
                    }
                }
            }
        },
        
        ActionItem
        {
            id: addPhone
            imageSource: "images/menu/ic_add_phone.png"
            title: qsTr("Add Phone") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            enabled: individualId != undefined
            
            onTriggered: {
                console.log("UserEvent: NewPhone");
                var phone = persist.showBlockingPrompt( qsTr("Enter phone number"), qsTr("Please enter the phone number for this individual:"), "", qsTr("Enter phone (ie: +44133441623)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Phone ).trim();
                
                if (phone.length > 0)
                {
                    if ( deviceUtils.isValidPhoneNumber(phone) ) {
                        var x = ilmHelper.addWebsite(individualId, phone);
                        adm.append(x);
                        persist.showToast( qsTr("Phone Number added!"), imageSource.toString() );
                        listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    } else {
                        persist.showToast( qsTr("Invalid phone number entered!"), "images/menu/ic_remove_phone.png" );
                        console.log("FailedRegex", phone);
                    }
                }
            }
        }
    ]
    
    onIndividualIdChanged: {
        if (individualId)
        {
            ilmHelper.fetchMentions(bioPage, individualId);
            ilmHelper.fetchRelations(bioPage, individualId);
            ilmHelper.fetchIndividualData(bioPage, individualId);
            ilmHelper.fetchAllWebsites(bioPage, individualId);
            tafsirHelper.fetchAllQuotes(bioPage, 0, individualId);
            tafsirHelper.fetchAllTafsir(bioPage, 0, individualId);
        }
    }

    function checkForDuplicate(result)
    {
        result.item_type = bios.itemType(result, []);
        var indexPath = bioModel.findExact(result);
        
        if (indexPath.length == 0) {
            bioModel.insert(result);
        }
        
        Qt.popToRoot(bioPage);
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchIndividualData && data.length > 0) {
            var metadata = data[0];
            
            var result = "";
            
            if (metadata.prefix) {
                result += metadata.prefix+" ";
            }
            
            result += metadata.name;
            
            titleBar.title = metadata.displayName ? metadata.displayName : metadata.name;
            
            if (metadata.kunya) {
                result += " (%1)".arg(metadata.kunya);
            }
            
            result += " ";
            
            if (metadata.birth && metadata.death) {
                result += "(%1)".arg( getHijriYear(metadata.birth, metadata.death) );
            } else if (metadata.birth) {
                result += qsTr("(born %1)").arg( getHijriYear(metadata.birth) );
            } else if (metadata.death) {
                result += qsTr("(died %1)").arg( getHijriYear(metadata.death) );
            }
            
            result += "\n";
            
            body.text = "\n"+result;
        } else if (id == QueryId.RemoveRelation) {
            persist.showToast( qsTr("Relationship removed!"), "images/menu/ic_remove_teacher.png" );
        } else if (id == QueryId.EditIndividual) {
            persist.showToast( qsTr("Profile updated!"), "images/menu/ic_edit_rijaal.png" );
        } else if (id == QueryId.EditQuote) {
            persist.showToast( qsTr("Quote updated!"), "images/menu/ic_edit_quote.png" );
        } else if (id == QueryId.ReplaceSuite) {
            persist.showToast( qsTr("Suite merged!"), "images/menu/ic_merge_into.png" );
            Qt.popToRoot(bioPage);
            reload();
            return;
        } else if (id == QueryId.EditSuitePage) {
            persist.showToast( qsTr("Tafsir page updated!"), "images/menu/ic_edit_suite_page.png" );
            Qt.popToRoot(bioPage);
        } else if (id == QueryId.EditSuite) {
            persist.showToast( qsTr("Suite updated!"), "images/menu/ic_edit_bio.png" );
            Qt.popToRoot(bioPage);
        } else if (id == QueryId.RemoveSuite) {
            persist.showToast( qsTr("Suite removed!"), "images/menu/ic_remove_suite.png" );
            Qt.popToRoot(bioPage);
        }  else if (id == QueryId.RemoveWebsite) {
            persist.showToast( qsTr("Entry removed!"), "asset:///images/menu/ic_remove_site.png" );
            ilmHelper.fetchAllWebsites(createRijaal, individualId);
        } else {
            for (var i = data.length-1; i >= 0; i--)
            {
                var current = data[i];
                current.item_type = bios.itemType(current, []);
                data[i] = current;
            }
            
            bioModel.insertList(data);
        }
    }
    
    titleBar: TitleBar
    {
        scrollBehavior: TitleBarScrollBehavior.NonSticky
        
        dismissAction: ActionItem
        {
            id: addBook
            imageSource: "images/menu/ic_add_book.png"
            title: qsTr("Add Book") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: AddBook");
                
                var name = persist.showBlockingPrompt( qsTr("Book Title"), qsTr("Please enter the name of this book:"), "", qsTr("Enter value"), 100, true, qsTr("Save"), qsTr("Cancel") ).trim();
                
                if (name.length > 0)
                {
                    var x = ilmHelper.addSuite(bioPage, individualId, 0, 0, name, "", name);
                    x.item_type = "work";
                    checkForDuplicate(x);
                }
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        TextArea
        {
            id: body
            editable: false
            backgroundVisible: false
            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
            input.flags: TextInputFlag.SpellCheckOff
            topPadding: 0;
            textStyle.fontSize: FontSize.Large
            bottomPadding: 0; bottomMargin: 0
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.textAlign: TextAlign.Center
            textStyle.fontWeight: FontWeight.Bold
            textStyle.fontStyle: FontStyle.Italic
            visible: text.length > 0
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: -1
            }
        }
        
        ProfileListView {
            id: bios
        }
    }
    
    function reload()
    {
        bioModel.clear();
        individualIdChanged();
    }
    
    function cleanUp() {}
}