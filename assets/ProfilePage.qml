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
    
    actions: [
        ActionItem
        {
            id: addRelation
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_student.png"
            title: qsTr("Add Relationship") + Retranslate.onLanguageChanged
            
            function onPicked(otherId, name)
            {
                relationDialog.target = otherId;
                relationDialog.name = name;
                relationDialog.show();
            }
            
            onTriggered: {
                console.log("UserEvent: AddRelationship");

                var p = Qt.launch("IndividualPickerPage.qml");
                p.picked.connect(onPicked);
                
                ilmHelper.fetchFrequentIndividuals(p.pickerList, "relationships", "individual");
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
            id: addSite
            imageSource: "images/menu/ic_add_site.png"
            title: qsTr("Add Contact") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: NewSite");
                var uri = persist.showBlockingPrompt( qsTr("Enter email/phone/url"), qsTr("Please enter the website address or phone number or email address for this individual:"), "", qsTr("Enter url (ie: http://mtws.com)"), 100, false, qsTr("Save"), qsTr("Cancel"), SystemUiInputMode.Url ).trim().toLowerCase();
                
                if (uri.length > 0)
                {
                    if ( uri.indexOf("@") == -1 && uri.indexOf("+") == -1 )
                    {
                        var corrected = offloader.fixUri(uri);
                        
                        if (corrected.length > 0) { // a url
                            uri = corrected;
                        } // otherwise take it for what it is
                    }
                    
                    var x = ilmHelper.addWebsite(individualId, uri);
                    checkForDuplicate(x);
                    bios.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                    persist.showToast( qsTr("Contact info added!"), imageSource.toString() );
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
            persist.showToast( qsTr("Entry removed!"), "images/menu/ic_remove_site.png" );
            ilmHelper.fetchAllWebsites(bioPage, individualId);
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
                    var x = tafsirHelper.addSuite(individualId, 0, 0, name, "", name, true);
                    x.title = name;
                    x.author = titleBar.title;
                    x.is_book = true;
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
    
    attachedObjects: [
        SystemListDialog
        {
            id: relationDialog
            property variant target
            property string name
            title: qsTr("Relationship Type") + Retranslate.onLanguageChanged
            body: qsTr("Please select the type of relationship this is:") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("Cancel")
            confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
            
            onFinished: {
                if (value == SystemUiResult.ConfirmButtonSelection)
                {
                    var selectedIndex = selectedIndices[0];
                    var individual = individualId;
                    var other = target;
                    var relationType = selectedIndex+1;
                    
                    if (selectedIndex == 0) {
                        individual = individualId;
                        other = target;
                        relationType = 2;
                    } else if  (selectedIndex == 1) {
                        other = individualId;
                        individual = target;
                        relationType = 2;
                    } else if  (selectedIndex == 2) {
                        individual = individualId;
                        other = target;
                        relationType = 1;
                    } else if  (selectedIndex == 3) {
                        other = individualId;
                        individual = target;
                        relationType = 1;
                    } else {
                        individual = individualId;
                        other = target;
                        relationType = selectedIndex == 4 ? 3 : selectedIndex == 5 ? 4 : 0;
                    }
                    
                    if (individual && target && relationType)
                    {
                        var result = ilmHelper.addRelation(individual, other, relationType);
                        result.id = individual;
                        result.name = name;
                        
                        checkForDuplicate(result);
                    }
                }
            }
        }
    ]
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(bioPage, bios);
        
        relationDialog.appendItem( qsTr("Teacher"), true, true );
        relationDialog.appendItem( qsTr("Student") );
        relationDialog.appendItem( qsTr("Parent") );
        relationDialog.appendItem( qsTr("Child") );
        relationDialog.appendItem( qsTr("Sibling") );
        relationDialog.appendItem( qsTr("Friend") );
    }
}