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
        sortingKeys: ["item_type", "uri", "name", "title", "heading"]
        grouping: ItemGrouping.ByFullValue
    }
    
    function getHeaderName(ListItemData)
    {
        if (ListItemData == "citing") {
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
        } else if (ListItemData == "friend") {
            return qsTr("Companions");
        } else if (ListItemData == "spouse") {
            return qsTr("Spouses");
        } else if (ListItemData == "translation") {
            return qsTr("Translations");
        } else if (ListItemData == "biography") {
            return qsTr("Biographies");
        } else if (ListItemData == "quote") {
            return qsTr("Quotes");
        } else if (ListItemData == "work") {
            return qsTr("Works");
        } else if (ListItemData == "address") {
            return qsTr("Contact Info");
        }
    }
    
    function itemType(data, indexPath)
    {
        if (indexPath.length == 1) {
            return "header";
        } else if (data.individual && data.other_id) { // relationship
            if (data.type == 1) { // parent/child
                return data.other_id == individualId ? "child" : "parent";
            } else if (data.type == 2) {
                return data.other_id == individualId ? "student" : "teacher";
            } else if (data.type == 3) {
                return "sibling";
            } else if (data.type == 4) {
                return "friend";
            } else {
                return "spouse";
            }
        } else if (data.points != undefined) {
            return data.points == 3 ? "translation" : data.points == 2 ? "biography" : "citing";
        } else if (data.uri) {
            return "address";
        } else if (data.book_name) {
            return "book";
        } else if (data.title) {
            return "work";
        } else {
            return "quote";
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
        var ipp = Qt.launch("TafsirPickerPage.qml");
        ipp.tafsirPicked.connect(onDestinationPicked);
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
    
    function onEditSuite(id, author, translator, explainer, title, description, reference, isBook)
    {
        var current = tafsirHelper.editSuite(bioPage, id, author, translator, explainer, title, description, reference, isBook);
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
        
        var ipp = Qt.launch("CreateTafsirPage.qml");
        ipp.createTafsir.connect(onEditSuite);
        ipp.deleteTafsir.connect(onDelete);
        ipp.suiteId = ListItemData.suite_id ? ListItemData.suite_id : ListItemData.id;
    }
    
    function deleteSite(ListItem, ListItemData)
    {
        ilmHelper.removeWebsite(bioPage, ListItemData.id);
        bioModel.removeAt(ListItem.indexPath);
        persist.showToast( qsTr("Contact info removed!"), "images/menu/ic_remove_site.png" )
    }
    
    function removeRelation(ListItem, ListItemData)
    {
        ilmHelper.removeRelation(bioPage, ListItemData.relation_id);
        bioModel.removeAt(ListItem.indexPath);
    }
    
    function removeQuote(ListItem, ListItemData)
    {
        ilmHelper.removeQuote(bioPage, ListItemData.id);
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
                var validIndividuals = {'teacher': 1, 'student': 1, 'parent': 1, 'sibling': 1, 'child': 1, 'friend': 1}
                
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
            type: "citing"
            
            AuthorshipListItem {
                imageSource: "images/list/ic_unique_narration.png"
            }
        },
        
        ListItemComponent
        {
            type: "translation"
            
            AuthorshipListItem {
                imageSource: "images/menu/ic_translate_quote.png"
            }
        },
        
        ListItemComponent
        {
            type: "biography"
            
            AuthorshipListItem {
                imageSource: "images/list/ic_bio.png"
            }
        },
        
        ListItemComponent
        {
            type: "work"
            
            AuthorshipListItem {}
        },
        
        ListItemComponent
        {
            type: "address"
            
            StandardListItem
            {
                id: addressSli
                imageSource: deviceUtils.isUrl(ListItemData.uri) ? ListItemData.uri.indexOf("wordpress.com") ? "images/list/site_wordpress.png" : ListItemData.uri.indexOf("twitter.com") ? "images/list/site_twitter.png" : ListItemData.uri.indexOf("facebook.com") ? "images/list/site_facebook.png" : ListItemData.uri.indexOf("soundcloud.com") ? "images/list/site_soundcloud.png" : ListItemData.uri.indexOf("youtube.com") ? "images/list/site_youtube.png" : "images/list/ic_phone.png" : deviceUtils.isValidEmail(ListItemData.uri) ? "images/list/ic_email.png" : "images/list/ic_phone.png"
                title: ListItemData.uri
                
                contextActions: [
                    ActionSet
                    {
                        title: addressSli.title
                        
                        DeleteActionItem
                        {
                            imageSource: "images/menu/ic_remove_phone.png"
                            
                            onTriggered: {
                                console.log("UserEvent: DeleteSite");
                                addressSli.ListItem.view.deleteSite(addressSli.ListItem, ListItemData);
                            }
                        }
                    }
                ]
            }
        },
        
        ListItemComponent
        {
            type: "teacher"
            
            RelationItem
            {
                imageSource: ListItemData.female ? "images/list/ic_teacher_female.png" : "images/list/ic_teacher.png"
                delImage: "images/menu/ic_remove_teacher.png"
            }
        },
        
        ListItemComponent
        {
            type: "spouse"
            
            RelationItem
            {
                imageSource: ListItemData.female ? "images/list/ic_female.png" : "images/dropdown/ic_scholar.png"
                delImage: "images/menu/ic_remove_child.png"
            }
        },
        
        ListItemComponent
        {
            type: "student"
            
            RelationItem
            {
                imageSource: ListItemData.female ? "images/list/ic_student_female.png" : "images/list/ic_student.png"
                delImage: "images/menu/ic_remove_student.png"
            }
        },
        
        ListItemComponent
        {
            type: "child"
            
            RelationItem
            {
                imageSource: ListItemData.female ? "images/list/ic_child_female.png" : "images/list/ic_child.png"
                delImage: "images/menu/ic_remove_child.png"
            }
        },
        
        ListItemComponent
        {
            type: "parent"
            
            RelationItem
            {
                imageSource: ListItemData.female ? "images/list/ic_parent_female.png" : "images/list/ic_parent.png"
                delImage: "images/menu/ic_remove_parent.png"
            }
        },
        
        ListItemComponent
        {
            type: "sibling"
            
            RelationItem
            {
                imageSource: ListItemData.female ? "images/list/ic_sibling_female.png" : "images/list/ic_sibling.png"
                delImage: "images/menu/ic_remove_sibling.png"
            }
        },
        
        ListItemComponent
        {
            type: "friend"
            
            RelationItem
            {
                imageSource: ListItemData.female ? "images/list/ic_sibling_female.png" : "images/list/ic_companion.png"
                delImage: "images/menu/ic_remove_companions.png"
            }
        },
        
        ListItemComponent
        {
            type: "quote"
            
            StandardListItem
            {
                id: quoteSli
                imageSource: "images/list/ic_quote.png"
                title: ListItemData.title ? "%1 %2".arg(ListItemData.title).arg(ListItemData.reference) : ListItemData.reference
                description: ListItemData.body
                
                contextActions: [
                    ActionSet
                    {
                        title: quoteSli.title
                        
                        DeleteActionItem
                        {
                            imageSource: "images/menu/ic_delete_quote.png"
                            
                            onTriggered: {
                                console.log("UserEvent: RemoveQuote");
                                quoteSli.ListItem.view.removeQuote(quoteSli.ListItem, ListItemData);
                            }
                        }
                    }
                ]
            }
        }
    ]
    
    onTriggered: {
        if (indexPath.length > 1)
        {
            var d = dataModel.data(indexPath);
            var type = itemType(d, indexPath);
            console.log("UserEvent: AttributeTapped", type);
            
            if (d.individual && d.other_id) {
                var page = Qt.launch("ProfilePage.qml");
                page.individualId = d.id;
            } else if (type == "citing" || type == "work" || type == "translation" || type == "biography") {
                editIndexPath = indexPath;
                var page = Qt.launch("TafsirContentsPage.qml");
                page.searchData = {'suitePageId': d.suite_page_id};
                page.suiteId = d.suite_id ? d.suite_id : d.id;
            } else if (type == "quote") {
                editIndexPath = indexPath;
                var page = Qt.launch("CreateQuotePage.qml");
                page.createQuote.connect(onEdit);
                page.quoteId = d.id;
            } else if (type == "address") {
                persist.openUri(d.uri);
            }
        }
    }
    
    function onEdit(id, author, translator, body, reference, suiteId, uri)
    {
        tafsirHelper.editQuote(bioPage, id, author, translator, body, reference, suiteId, uri);
        Qt.popToRoot(bioPage);
    }
    
    layoutProperties: StackLayoutProperties {
        spaceQuota: 1
    }
}