import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: bioPage
    property variant individualId
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
                tafsirHelper.addStudent(bioPage, individualId, student);
                checkForDuplicate( {'id': student, 'student': name, 'type': "student"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddStudent");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                
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
                tafsirHelper.addTeacher(bioPage, individualId, teacher);
                checkForDuplicate( {'id': teacher, 'teacher': name, 'type': "teacher"} );
            }
            
            onTriggered: {
                console.log("UserEvent: AddTeacher");
                definition.source = "IndividualPickerPage.qml";
                
                var p = definition.createObject();
                p.picked.connect(onPicked);
                
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
            
            function onEdit(id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion)
            {
                tafsirHelper.editIndividual(bioPage, id, prefix, name, kunya, displayName, hidden, birth, death, female, location, companion);
                
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
                tafsirHelper.addParent(bioPage, individualId, parentId);
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
                tafsirHelper.addSibling(bioPage, individualId, siblingId);
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
                tafsirHelper.addChild(bioPage, individualId, child);
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
            tafsirHelper.fetchBio(bioPage, individualId);
            tafsirHelper.fetchIndividualData(bioPage, individualId);
            tafsirHelper.fetchTeachers(bioPage, individualId);
            tafsirHelper.fetchStudents(bioPage, individualId);
            tafsirHelper.fetchParents(bioPage, individualId);
            tafsirHelper.fetchSiblings(bioPage, individualId);
            tafsirHelper.fetchChildren(bioPage, individualId);
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
            ft.play();
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
        } else if (id == QueryId.AddParent) {
            persist.showToast( qsTr("Parent added!"), "images/menu/ic_add_parent.png" );
        } else if (id == QueryId.AddSibling) {
            persist.showToast( qsTr("Sibling added!"), "images/menu/ic_add_sibling.png" );
        } else if (id == QueryId.AddChild) {
            persist.showToast( qsTr("Child added!"), "images/menu/ic_add_child.png" );
        } else if (id == QueryId.EditIndividual) {
            persist.showToast( qsTr("Profile updated!"), "images/menu/ic_edit_rijaal.png" );
        } else if (id == QueryId.ReplaceSuite) {
            persist.showToast( qsTr("Suite merged!"), "images/menu/ic_merge.png" );
            popToRoot();
            reload();
            return;
        } else if (id == QueryId.EditTafsirPage) {
            persist.showToast( qsTr("Tafsir page updated!"), "images/menu/ic_edit_suite_page.png" );
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
                tafsirHelper.addBioLink(navigationPane, suites[0]);
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
        
        ListView
        {
            id: bios
            property variant editIndexPath
            scrollRole: ScrollRole.Main
            
            layout: StackListLayout {
                headerMode: ListHeaderMode.Sticky
            }
            
            dataModel: GroupDataModel
            {
                id: bioModel
                sortingKeys: ["type", "uri", "teacher", "student"]
                grouping: ItemGrouping.ByFullValue
            }
            
            function getHeaderName(ListItemData)
            {
                if (ListItemData == "bio") {
                    return qsTr("Biographies");
                } else if (ListItemData == "citing") {
                    return qsTr("Citings");
                } else if (ListItemData == "teacher") {
                    return qsTr("Teachers");
                } else if (ListItemData == "student") {
                    return qsTr("Students");
                } else if (ListItemData == "parent") {
                    return qsTr("Parents");
                } else if (ListItemData == "sibling") {
                    return qsTr("Siblings");
                } else if (ListItemData == "child") {
                    return qsTr("Children");
                }
            }
            
            function itemType(data, indexPath)
            {
                if (indexPath.length == 1) {
                    return "header";
                } else {
                    return data.type;
                }
            }
            
            function onDestinationPicked(suites)
            {
                var destination = suites[0].id;
                tafsirHelper.mergeSuites(bioPage, [dataModel.data(editIndexPath).suite_id], destination);
            }
            
            function merge(ListItem)
            {
                editIndexPath = ListItem.indexPath;
                definition.source = "TafsirPickerPage.qml";
                var ipp = definition.createObject();
                ipp.tafsirPicked.connect(onDestinationPicked);
                
                navigationPane.push(ipp);
            }
            
            function checkLinks(ListItemData)
            {
                definition.source = "TafsirAyats.qml";
                var ipp = definition.createObject();
                ipp.suitePageId = ListItemData.suite_page_id;
                
                navigationPane.push(ipp);
            }
            
            function onEditSuitePage(id, body, header, reference)
            {
                var x = dataModel.data(editIndexPath);
                x["body"] = body;
                x["heading"] = header;
                x["reference"] = reference;
                bioModel.updateItem(editIndexPath, x);
                
                tafsirHelper.editTafsirPage(bioPage, id, body, header, reference);
            }
            
            function removeStudent(ListItem)
            {
                tafsirHelper.removeStudent(bioPage, individualId, ListItem.data.id);
                bioModel.removeAt(ListItem.indexPath);
            }
            
            function removeChild(ListItem)
            {
                tafsirHelper.removeChild(bioPage, individualId, ListItem.data.id);
                bioModel.removeAt(ListItem.indexPath);
            }
            
            function removeTeacher(ListItem)
            {
                tafsirHelper.removeTeacher(bioPage, individualId, ListItem.data.id);
                bioModel.removeAt(ListItem.indexPath);
            }
            
            function removeSibling(ListItem)
            {
                tafsirHelper.removeSibling(bioPage, individualId, ListItem.data.id);
                bioModel.removeAt(ListItem.indexPath);
            }
            
            function removeParent(ListItem)
            {
                tafsirHelper.removeParent(bioPage, individualId, ListItem.data.id);
                bioModel.removeAt(ListItem.indexPath);
            }
            
            onSelectionChanged: {
                var n = selectionList().length;
                multiSelectHandler.status = qsTr("%n entries selected", "", n);
                selectMulti.enabled = n > 0;
            }
            
            multiSelectAction: MultiSelectActionItem {
                imageSource: "images/menu/ic_select_individuals.png"
            }
            
            multiSelectHandler.actions: [
                ActionItem
                {
                    id: selectMulti
                    enabled: false
                    imageSource: "images/menu/ic_set_companions.png"
                    title: qsTr("Select") + Retranslate.onLanguageChanged
                    
                    onTriggered: {
                        console.log("UserEvent: MultiProfileSelect");
                        
                        var all = bios.selectionList();
                        var ids = [];
                        var validIndividuals = {'teacher': 1, 'student': 1, 'parent': 1, 'sibling': 1, 'child': 1}
                        
                        for (var i = all.length-1; i >= 0; i--)
                        {
                            var d = bioModel.data(all[i]);
                            
                            if ( bios.itemType(d, all[i]) in validIndividuals ) {
                                ids.push(d.id);
                            }
                        }
                        
                        individualsPicked(ids);
                    }
                }
            ]
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "header"
                    
                    Header
                    {
                        id: header
                        title: header.ListItem.view.getHeaderName(ListItemData)
                        subtitle: header.ListItem.view.dataModel.childCount(header.ListItem.indexPath)
                    }
                },
                
                ListItemComponent
                {
                    type: "bio"
                    
                    StandardListItem
                    {
                        id: bioSli
                        description: ListItemData.heading ? ListItemData.heading : ListItemData.title ? ListItemData.title : ""
                        imageSource: ListItemData.points > 0 ? "images/list/ic_like.png" : ListItemData.points < 0 ? "images/list/ic_dislike.png" : "images/list/ic_bio.png"
                        title: ListItemData.author ? ListItemData.author : ListItemData.reference ? ListItemData.reference : ""
                        
                        contextActions: [
                            ActionSet
                            {
                                title: bioSli.title
                                subtitle: bioSli.description
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_merge.png"
                                    title: qsTr("Merge Into") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: MergeSuite");
                                        bioSli.ListItem.view.merge(bioSli.ListItem);
                                    }
                                }
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_update_link.png"
                                    title: qsTr("Check Links") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: CheckLinks");
                                        bioSli.ListItem.view.checkLinks(ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "citing"
                    
                    StandardListItem
                    {
                        description: ListItemData.heading ? ListItemData.heading : ListItemData.title ? ListItemData.title : ""
                        imageSource: "images/list/ic_tafsir.png"
                        title: ListItemData.author ? ListItemData.author : ListItemData.reference ? ListItemData.reference : ""
                    }
                },
                
                ListItemComponent
                {
                    type: "teacher"
                    
                    StandardListItem
                    {
                        id: teacherSli
                        imageSource: ListItemData.female ? "images/list/ic_teacher_female.png" : "images/list/ic_teacher.png"
                        title: ListItemData.teacher
                        
                        contextActions: [
                            ActionSet
                            {
                                title: teacherSli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_teacher.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveTeacher");
                                        teacherSli.ListItem.view.removeTeacher(teacherSli.ListItem);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "student"
                    
                    StandardListItem
                    {
                        id: studentSli
                        imageSource: ListItemData.female ? "images/list/ic_female.png" : "images/list/ic_student.png"
                        title: ListItemData.student
                        
                        contextActions: [
                            ActionSet
                            {
                                title: studentSli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_student.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveStudent");
                                        studentSli.ListItem.view.removeStudent(studentSli.ListItem);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "child"
                    
                    StandardListItem
                    {
                        id: childSli
                        imageSource: ListItemData.female ? "images/list/ic_child_female.png" : "images/list/ic_child.png"
                        title: ListItemData.child
                        
                        contextActions: [
                            ActionSet
                            {
                                title: childSli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_child.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveChild");
                                        childSli.ListItem.view.removeChild(childSli.ListItem);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "parent"
                    
                    StandardListItem
                    {
                        id: parentSli
                        imageSource: ListItemData.female ? "images/list/ic_parent_female.png" : "images/list/ic_parent.png"
                        title: ListItemData.parent
                        
                        contextActions: [
                            ActionSet
                            {
                                title: parentSli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_parent.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveParent");
                                        parentSli.ListItem.view.removeParent(parentSli.ListItem);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "sibling"
                    
                    StandardListItem
                    {
                        id: siblingSli
                        imageSource: ListItemData.female ? "images/list/ic_female.png" : "images/list/ic_sibling.png"
                        title: ListItemData.sibling
                        
                        contextActions: [
                            ActionSet
                            {
                                title: siblingSli.title
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_sibling.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveSibling");
                                        siblingSli.ListItem.view.removeSibling(siblingSli.ListItem);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
            
            onTriggered: {
                if (indexPath.length == 1) {
                    console.log("UserEvent: HeaderTapped");
                    return;
                }
                
                var d = dataModel.data(indexPath);
                console.log("UserEvent: AttributeTapped", d.type);
                
                if (d.type == "student" || d.type == "teacher" || d.type == "child" || d.type == "parent" || d.type == "sibling") {
                    definition.source = "ProfilePage.qml";
                    var page = definition.createObject();
                    page.individualId = d.id;
                    
                    navigationPane.push(page);
                } else if (d.type == "bio" || d.type == "citing") {
                    editIndexPath = indexPath;
                    definition.source = "CreateSuitePage.qml";
                    var page = definition.createObject();
                    page.suitePageId = d.suite_page_id;
                    page.createSuitePage.connect(onEditSuitePage);
                    
                    navigationPane.push(page);
                }
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
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