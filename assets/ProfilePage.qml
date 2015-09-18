import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: bioPage
    property variant individualId
    property alias bioModel: bios.dataModel
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal individualsPicked(variant ids)
    
    actions: [
        ActionItem
        {
            id: addStudent
            ActionBar.placement: ActionBarPlacement.OnBar
            imageSource: "images/menu/ic_add_student.png"
            title: qsTr("Add Student") + Retranslate.onLanguageChanged
            
            function onPicked(student, name)
            {
                ilmHelper.addStudent(bioPage, individualId, student);
                checkForDuplicate( {'id': student, 'student': name, 'type': "student"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddStudent");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                ilmHelper.fetchFrequentIndividuals(p.pickerList, "teachers", "individual");
                
                navigationPane.push(p);
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
                ilmHelper.addTeacher(bioPage, individualId, teacher);
                checkForDuplicate( {'id': teacher, 'teacher': name, 'type': "teacher"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddTeacher");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                ilmHelper.fetchFrequentIndividuals(p.pickerList, "teachers", "teacher");
                
                navigationPane.push(p);
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
                
                popToRoot();
                reload();
            }
            
            onTriggered: {
                console.log("UserEvent: EditBio");
                
                definition.source = "CreateIndividualPage.qml";
                
                var p = definition.createObject();
                p.individualId = individualId;
                p.createIndividual.connect(onEdit);
                
                navigationPane.push(p);
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
                ilmHelper.addParent(bioPage, individualId, parentId);
                checkForDuplicate( {'id': parentId, 'parent': name, 'type': "parent"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddParent");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                
                navigationPane.push(p);
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
                ilmHelper.addSibling(bioPage, individualId, siblingId);
                checkForDuplicate( {'id': siblingId, 'sibling': name, 'type': "sibling"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddSibling");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                
                navigationPane.push(p);
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
                ilmHelper.addChild(bioPage, individualId, child);
                checkForDuplicate( {'id': child, 'child': name, 'type': "child"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddChild");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                
                navigationPane.push(p);
            }
        }
    ]
    
    onIndividualIdChanged: {
        if (individualId)
        {
            ilmHelper.fetchBio(bioPage, individualId);
            ilmHelper.fetchIndividualData(bioPage, individualId);
            ilmHelper.fetchTeachers(bioPage, individualId);
            ilmHelper.fetchStudents(bioPage, individualId);
            ilmHelper.fetchParents(bioPage, individualId);
            ilmHelper.fetchSiblings(bioPage, individualId);
            ilmHelper.fetchChildren(bioPage, individualId);
            ilmHelper.fetchBooksForAuthor(bioPage, individualId);
        }
    }
    
    function popToRoot()
    {
        while (navigationPane.top != bioPage) {
            navigationPane.pop();
        }
    }
    
    function checkForDuplicate(result)
    {
        var indexPath = bioModel.findExact(result);
        
        if (indexPath.length == 0) {
            bioModel.insert(result);
        }
        
        popToRoot();
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
                result += "(%1)".arg( global.getHijriYear(metadata.birth, metadata.death) );
            } else if (metadata.birth) {
                result += qsTr("(born %1)").arg( global.getHijriYear(metadata.birth) );
            } else if (metadata.death) {
                result += qsTr("(died %1)").arg( global.getHijriYear(metadata.death) );
            }
            
            result += "\n";
            
            body.text = "\n"+result;
        } else if (id == QueryId.RemoveTeacher) {
            persist.showToast( qsTr("Teacher removed!"), "images/menu/ic_remove_teacher.png" );
        } else if (id == QueryId.RemoveStudent) {
            persist.showToast( qsTr("Student removed!"), "images/menu/ic_remove_student.png" );
        } else if (id == QueryId.RemoveChild) {
            persist.showToast( qsTr("Child removed!"), "images/menu/ic_remove_companions.png" );
        } else if (id == QueryId.AddTeacher) {
            persist.showToast( qsTr("Teacher added!"), "images/menu/ic_set_companions.png" );
        } else if (id == QueryId.AddStudent) {
            persist.showToast( qsTr("Student added!"), "images/menu/ic_add_student.png" );
        } else if (id == QueryId.RemoveParent) {
            persist.showToast( qsTr("Parent removed!"), "images/menu/ic_remove_parent.png" );
        } else if (id == QueryId.RemoveSibling) {
            persist.showToast( qsTr("Sibling removed!"), "images/menu/ic_remove_sibling.png" );
        } else if (id == QueryId.RemoveBook) {
            persist.showToast( qsTr("Book removed!"), "images/menu/ic_remove_book.png" );
        } else if (id == QueryId.AddParent) {
            persist.showToast( qsTr("Parent added!"), "images/menu/ic_add_parent.png" );
        } else if (id == QueryId.AddSibling) {
            persist.showToast( qsTr("Sibling added!"), "images/menu/ic_add_sibling.png" );
        } else if (id == QueryId.AddBook) {
            persist.showToast( qsTr("Book added!"), "images/menu/ic_add_sibling.png" );
        } else if (id == QueryId.EditIndividual) {
            persist.showToast( qsTr("Profile updated!"), "images/menu/ic_edit_rijaal.png" );
        } else if (id == QueryId.ReplaceSuite) {
            persist.showToast( qsTr("Suite merged!"), "images/menu/ic_merge_into.png" );
            popToRoot();
            reload();
            return;
        } else if (id == QueryId.EditSuitePage) {
            persist.showToast( qsTr("Tafsir page updated!"), "images/menu/ic_edit_suite_page.png" );
            popToRoot();
        } else if (id == QueryId.EditSuite) {
            persist.showToast( qsTr("Suite updated!"), "images/menu/ic_edit_bio.png" );
            popToRoot();
        } else if (id == QueryId.RemoveSuite) {
            persist.showToast( qsTr("Suite removed!"), "images/menu/ic_remove_suite.png" );
            popToRoot();
        } else if (id == QueryId.AddBioLink) {
            persist.showToast( qsTr("Biography added!!"), "images/menu/ic_add_bio.png" );
            popToRoot();
            reload();
            return;
        }
        
        data = offloader.fillType(data, id);
        bioModel.insertList(data);
    }
    
    titleBar: TitleBar
    {
        scrollBehavior: TitleBarScrollBehavior.NonSticky
        
        acceptAction: ActionItem
        {
            id: addBio
            imageSource: "images/menu/ic_add_bio.png"
            title: qsTr("Add Bio") + Retranslate.onLanguageChanged
            
            function onSuitePicked(suites)
            {
                ilmHelper.addBioLink(navigationPane, suites[0]);
                popToRoot();
            }
            
            onTriggered: {
                console.log("UserEvent: AddProfileBio");
                definition.source = "TafsirPickerPage.qml";
                var page = definition.createObject();
                page.tafsirPicked.connect(onSuitePicked);
                page.autoFocus = true;
                page.reload();
                
                navigationPane.push(page);
            }
        }
        
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
                    var x = ilmHelper.addBook(individualId, name);
                    x.type = "book";
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
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
    
    function reload()
    {
        bioModel.clear();
        individualIdChanged();
    }
    
    function cleanUp() {}
}