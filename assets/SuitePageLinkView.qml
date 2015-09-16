import bb.cascades 1.3
import com.canadainc.data 1.0

ListView
{
    id: listView
    scrollRole: ScrollRole.Main
    
    dataModel: ArrayDataModel {
        id: adm
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAyatsForTafsir || id == QueryId.FetchBioMetadata || id == QueryId.FetchQuestionsForSuitePage)
        {
            if ( adm.isEmpty() )
            {
                if (data.length > 0) {
                    adm.append(data);
                }
            } else { // do diff
                app.doDiff(data, adm);
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
            }
            
            busy.delegateActive = false;
        } else if (id == QueryId.UnlinkAyatsFromTafsir) {
            persist.showToast( qsTr("Ayat unlinked from tafsir"), "images/menu/ic_unlink_tafsir_ayat.png" );
            busy.delegateActive = false;
        } else if (id == QueryId.LinkAyatsToTafsir) {
            persist.showToast( qsTr("Ayat linked to tafsir!"), "images/menu/ic_link_ayat_to_tafsir.png" );
            suitePageIdChanged();
            popToRoot();
            busy.delegateActive = false;
        } else if (id == QueryId.UpdateTafsirLink) {
            persist.showToast( qsTr("Ayat link updated"), "images/menu/ic_edit_link.png" );
            busy.delegateActive = false;
        } else if (id == QueryId.EditBioLink) {
            persist.showToast( qsTr("Biography link updated"), "images/menu/ic_bio_link_edit.png" );
            busy.delegateActive = false;
        } else if (id == QueryId.EditQuestion) {
            persist.showToast( qsTr("Question updated"), "images/toast/ic_question_edited.png" );
            busy.delegateActive = false;
        } else if (id == QueryId.RemoveBioLink) {
            persist.showToast( qsTr("Biography unlinked!"), "images/menu/ic_remove_bio.png" );
            busy.delegateActive = false;
        } else if (id == QueryId.RemoveQuestion) {
            persist.showToast( qsTr("Question removed!"), "images/menu/ic_remove_question.png" );
            busy.delegateActive = false;
        } else if (id == QueryId.AddBioLink) {
            persist.showToast( qsTr("Biography linked!"), "images/dropdown/save_bio.png" );
            suitePageIdChanged();
            busy.delegateActive = false;
        } else if (id == QueryId.UpdateSortOrder) {
            persist.showToast( qsTr("Sort order updated!"), "images/dropdown/save_bio.png" );
            busy.delegateActive = false;
        }
        
        listView.visible = !adm.isEmpty();
        noElements.delegateActive = !listView.visible;
    }
    
    function onPeoplePicked(ids)
    {
        popToRoot();
        
        bioTypeDialog.target = ids;
        bioTypeDialog.show();
    }
    
    function onQuestionSaved(id, standardBody, standardNegation, boolStandard, promptStandard, orderedBody, countBody, boolCount, promptCount, afterBody, beforeBody, difficulty, choices, sourceId)
    {
        var edited = ilmTest.editQuestion(listView, id, standardBody, standardNegation, boolStandard, promptStandard, orderedBody, countBody, boolCount, promptCount, afterBody, beforeBody, difficulty, sourceId);
        adm.replace(prompt.indexPath[0], edited);
        
        if (choices.length > 0 && orderedBody.length > 0) {
            ilmTest.updateSortOrders(listView, choices);
        }
        
        popToRoot();
    }
    
    onTriggered: {
        console.log("UserEvent: TafsirAyatTriggered");
        
        var d = dataModel.data(indexPath);
        var t = itemType(d, indexPath);
        definition.source = "AyatPage.qml";
        
        if (t == "ayat")
        {
            if (d.from_verse_number) {
                persist.invoke( "com.canadainc.Quran10.previewer", "", "", "quran://%1/%2".arg(d.surah_id).arg(d.from_verse_number) );
            } else {
                persist.invoke( "com.canadainc.Quran10.ayat.picker", "ayatPicked", "", "", d.surah_id );
                prompt.indexPath = indexPath;
            }
        } else if (t == "question") {
            definition.source = "CreateQuestionPage.qml";
            var page = definition.createObject();
            
            page.questionId = d.id;
            page.saveQuestion.connect(onQuestionSaved);
            prompt.indexPath = indexPath;
            navigationPane.push(page);
        } else {
            definition.source = "ProfilePage.qml";
            var page = definition.createObject();
            page.individualsPicked.connect(onPeoplePicked);
            page.individualId = d.target_id;
            
            navigationPane.push(page);
        }
    }
    
    function duplicateQuestion(ListItem, ListItemData)
    {
        definition.source = "CreateQuestionPage.qml";
        var page = definition.createObject();
        page.sourceId = ListItemData.source_id ? ListItemData.source_id : ListItemData.id;
        page.saveQuestion.connect(addQuestion.onQuestionSaved);
        navigationPane.push(page);
    }
    
    function removeBioLink(ListItem)
    {
        busy.delegateActive = true;
        ilmHelper.removeBioLink(listView, ListItem.data.id);
        adm.removeAt(ListItem.indexPath[0]);
    }
    
    function removeQuestion(ListItem, ListItemData)
    {
        busy.delegateActive = true;
        ilmTest.removeQuestion(listView, ListItemData.id);
        adm.removeAt(ListItem.indexPath[0]);
    }
    
    function updateLink(ListItem)
    {
        var chapter = ListItem.data.surah_id;
        var fromVerse = ListItem.data.from_verse_number;
        var toVerse = ListItem.data.to_verse_number;
        
        var defaultText = chapter+":";
        
        if (fromVerse > 0)
        {
            defaultText += fromVerse;
            
            if (toVerse >= fromVerse) {
                defaultText += "-"+toVerse;
            }
        }
        
        prompt.indexPath = ListItem.indexPath;
        prompt.inputField.defaultText = defaultText;
        prompt.show();
    }
    
    function updateBioLink(ListItem)
    {
        prompt.indexPath = ListItem.indexPath;
        bioTypeDialog.target = undefined;
        bioTypeDialog.show();
    }
    
    function unlink(ListItem)
    {
        busy.delegateActive = true;
        quran.unlinkAyatsForTafsir(listView, [ListItem.data.id], suitePageId);
        adm.removeAt(ListItem.indexPath[0]);
    }
    
    function itemType(data, indexPath)
    {
        if (data.surah_id) {
            return "ayat";
        } else if (data.standard_body) {
            return "question"
        } else {
            return "bio";
        }
    }
    
    listItemComponents: [
        ListItemComponent
        {
            type: "bio"
            
            StandardListItem
            {
                id: bioRoot
                title: ListItemData.target
                imageSource: ListItemData.points > 1 ? "images/list/ic_tafsir.png" : ListItemData.points > 0 ? "images/list/ic_like.png" : ListItemData.points < 0 ? "images/list/ic_dislike.png" : "images/tabs/ic_bio.png"
                
                contextActions: [
                    ActionSet
                    {
                        title: bioRoot.title
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_bio_link_edit.png"
                            title: qsTr("Edit") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: UpdateBioLink");
                                bioRoot.ListItem.view.updateBioLink(bioRoot.ListItem);
                            }
                        }
                        
                        DeleteActionItem
                        {
                            imageSource: "images/menu/ic_remove_bio.png"
                            
                            onTriggered: {
                                console.log("UserEvent: DeleteBioLink");
                                bioRoot.ListItem.view.removeBioLink(bioRoot.ListItem);
                            }
                        }
                    }
                ]
            }
        },
        
        ListItemComponent
        {
            type: "ayat"
            
            StandardListItem
            {
                id: rootItem
                description: ListItemData.from_verse_number+"-"+ListItemData.to_verse_number
                imageSource: "images/list/ic_tafsir_ayat.png"
                title: ListItemData.surah_id
                status: ListItemData.id
                
                contextActions: [
                    ActionSet
                    {
                        title: rootItem.title
                        subtitle: rootItem.status
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_edit_link.png"
                            title: qsTr("Edit") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: UpdateAyatTafsirLink");
                                rootItem.ListItem.view.updateLink(rootItem.ListItem);
                            }
                        }
                        
                        DeleteActionItem
                        {
                            imageSource: "images/menu/ic_unlink_tafsir_ayat.png"
                            title: qsTr("Unlink") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: UnlinkAyatFromTafsir");
                                rootItem.ListItem.view.unlink(rootItem.ListItem);
                            }
                        }
                    }
                ]
            }
        },
        
        ListItemComponent
        {
            type: "question"
            
            StandardListItem
            {
                id: qsli
                imageSource: ListItemData.source_id ? "images/list/ic_question_alias.png" : "images/list/ic_question.png"
                status: ListItemData.difficulty ? ListItemData.difficulty.toString() : ""
                title: ListItemData.standard_body ? ListItemData.standard_body : ""
                
                contextActions: [
                    ActionSet
                    {
                        title: qsli.title
                        subtitle: qsli.status
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_edit_link.png"
                            title: qsTr("Duplicate") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: DuplicateQuestion");
                                qsli.ListItem.view.duplicateQuestion(qsli.ListItem, ListItemData);
                            }
                        }
                        
                        DeleteActionItem
                        {
                            imageSource: "images/menu/ic_remove_question.png"
                            
                            onTriggered: {
                                console.log("UserEvent: RemoveQuestion");
                                qsli.ListItem.view.removeQuestion(qsli.ListItem, ListItemData);
                            }
                        }
                    }
                ]
            }
        }
    ]
}