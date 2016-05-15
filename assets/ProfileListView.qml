import bb.cascades 1.3

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
        sortingKeys: ["type", "uri", "teacher", "student", "name"]
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
        } else if (ListItemData == "book") {
            return qsTr("Books");
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
        definition.source = "SuitePageLinks.qml";
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
        
        tafsirHelper.editSuitePage(bioPage, id, body, header, reference);
    }
    
    function onEditSuite(id, author, translator, explainer, title, description, reference)
    {
        var current = tafsirHelper.editSuite(bioPage, id, author, translator, explainer, title, description, reference);
        bioModel.updateItem(editIndexPath, current);
    }
    
    function onDelete(id)
    {
        tafsirHelper.removeSuite(bioPage, id);
        bioModel.removeAt(editIndexPath);
    }
    
    function editBio(ListItem, ListItemData)
    {
        editIndexPath = ListItem.indexPath;
        
        definition.source = "CreateTafsirPage.qml";
        var ipp = definition.createObject();
        ipp.createTafsir.connect(onEditSuite);
        ipp.suiteId = ListItemData.suite_id;
        ipp.deleteTafsir.connect(onDelete);
        
        navigationPane.push(ipp);
    }
    
    function removeStudent(ListItem)
    {
        ilmHelper.removeStudent(bioPage, individualId, ListItem.data.id);
        bioModel.removeAt(ListItem.indexPath);
    }
    
    function removeChild(ListItem)
    {
        ilmHelper.removeChild(bioPage, individualId, ListItem.data.id);
        bioModel.removeAt(ListItem.indexPath);
    }
    
    function removeTeacher(ListItem)
    {
        ilmHelper.removeTeacher(bioPage, individualId, ListItem.data.id);
        bioModel.removeAt(ListItem.indexPath);
    }
    
    function removeSibling(ListItem)
    {
        ilmHelper.removeSibling(bioPage, individualId, ListItem.data.id);
        bioModel.removeAt(ListItem.indexPath);
    }
    
    function removeParent(ListItem)
    {
        ilmHelper.removeParent(bioPage, individualId, ListItem.data.id);
        bioModel.removeAt(ListItem.indexPath);
    }
    
    function removeBook(ListItem)
    {
        ilmHelper.removeBook(bioPage, ListItem.data.id);
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
                
                if (ids.length > 0) {
                    individualsPicked(ids);
                }
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
                            imageSource: "images/menu/ic_update_link.png"
                            title: qsTr("Check Links") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CheckLinks");
                                bioSli.ListItem.view.checkLinks(ListItemData);
                            }
                        }
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_edit_bio.png"
                            title: qsTr("Edit") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: EditBio");
                                bioSli.ListItem.view.editBio(bioSli.ListItem, ListItemData);
                            }
                        }
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_merge_into.png"
                            title: qsTr("Merge Into") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: MergeSuite");
                                bioSli.ListItem.view.merge(bioSli.ListItem);
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
                imageSource: "images/list/ic_unique_narration.png"
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
                imageSource: ListItemData.female ? "images/list/ic_student_female.png" : "images/list/ic_student.png"
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
                imageSource: ListItemData.female ? "images/list/ic_sibling_female.png" : "images/list/ic_sibling.png"
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
        },
        
        ListItemComponent
        {
            type: "book"
            
            StandardListItem
            {
                id: bookSli
                imageSource: "images/list/ic_book.png"
                title: ListItemData.name
                
                contextActions: [
                    ActionSet
                    {
                        title: bookSli.title
                        
                        DeleteActionItem
                        {
                            imageSource: "images/menu/ic_remove_book.png"
                            
                            onTriggered: {
                                console.log("UserEvent: RemoveBook");
                                bookSli.ListItem.view.removeBook(bookSli.ListItem);
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