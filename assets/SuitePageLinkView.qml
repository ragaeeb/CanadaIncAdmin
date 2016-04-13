import bb.cascades 1.4
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
        if (id == QueryId.FetchAyatsForTafsir || id == QueryId.FetchNarrationsForSuitePage || id == QueryId.FetchBioMetadata || id == QueryId.FetchQuestionsForSuitePage)
        {
            if ( adm.isEmpty() ) {
                adm.append(data);
            } else { // do diff
                app.doDiff(data, adm);
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
            }
            
            busy.delegateActive = false;
        } else if (id == QueryId.UnlinkAyatsFromTafsir) {
            persist.showToast( qsTr("Ayat unlinked from tafsir"), "images/menu/ic_unlink_tafsir_ayat.png" );
            busy.delegateActive = false;
        } else if (id == QueryId.UnlinkNarrationsFromSuitePage) {
            persist.showToast( qsTr("Narration unlinked from suite page"), "images/menu/ic_unlink_narration.png" );
            busy.delegateActive = false;
        } else if (id == QueryId.LinkNarrationsToSuitePage) {
            persist.showToast( qsTr("Narration linked to suite page"), "images/menu/ic_add_narration.png" );
            busy.delegateActive = false;
            suitePageIdChanged();
        } else if (id == QueryId.LinkAyatToSuitePage) {
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
        } else if (id == QueryId.SearchNarrations && data.length > 0) {
            definition.source = "NarrationPickerPage.qml";
            persist.showToast( qsTr("Similar narrations found. Choose the ones you want to link."), "images/toast/similar_found.png" );
            var p = definition.createObject();
            p.picked.connect(onNarrationsPicked);
            p.populateAndSelect(data);
            
            navigationPane.push(p);
        }
        
        listView.visible = !adm.isEmpty();
        noElements.delegateActive = !listView.visible;
    }
    
    function onNarrationsPicked(elements)
    {
        var all = [];
        
        for (var i = elements.length-1; i >= 0; i--) {
            all.push(elements[i].narration_id);
        }
        
        sunnah.linkNarrationsToSuitePage(listView, suitePageId, all);
        popToRoot();
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
        } else if (t == "narration") {
            persist.invoke("com.canadainc.Sunnah10.shortcut", "bb.action.VIEW", "", "sunnah://id/"+d.narration_id);
        } else {
            definition.source = "ProfilePage.qml";
            var page = definition.createObject();
            page.individualsPicked.connect(onPeoplePicked);
            page.individualId = d.target_id;
            
            navigationPane.push(page);
        }
    }
    
    function produceQuestion(ListItemData, standardBody, boolStandard, promptStandard)
    {
        definition.source = "CreateQuestionPage.qml";
        var page = definition.createObject();
        page.setBodies(standardBody.arg(ListItemData.target), boolStandard.arg(ListItemData.target).arg("%1"), promptStandard.arg(ListItemData.target).arg("%1"));
        page.saveQuestion.connect(addQuestion.onQuestionSaved);
        navigationPane.push(page);
    }
    
    function duplicateQuestion(ListItem, ListItemData)
    {
        definition.source = "CreateQuestionPage.qml";
        var page = definition.createObject();
        page.sourceFrom(ListItemData.id, ListItemData.source_id);
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
    
    function unlinkNarration(ListItem)
    {
        busy.delegateActive = true;
        sunnah.unlinkNarrationsFromSuitePage(listView, [ListItem.data.narration_id], suitePageId);
        adm.removeAt(ListItem.indexPath[0]);
    }
    
    function itemType(data, indexPath)
    {
        if (data.surah_id) {
            return "ayat";
        } else if (data.standard_body) {
            return "question"
        } else if (data.narration_id) {
            return "narration"
        } else {
            return "bio";
        }
    }
    
    onSelectionChangeEnded: {        
        linkAction.enabled = selectionList().length > 0;
    }
    
    multiSelectHandler.actions: [
        LinkActionItem {
            id: linkAction
        }
    ]
    
    listItemComponents: [
        ListItemComponent
        {
            type: "bio"
            
            BiographyListItem {}
        },
        
        ListItemComponent
        {
            type: "ayat"
            
            AyatListItem {}
        },
        
        ListItemComponent
        {
            type: "narration"
            
            Container
            {
                id: narrationRoot
                horizontalAlignment: HorizontalAlignment.Fill
                leftPadding: 10; rightPadding: 10; bottomPadding: 10
                
                Header {
                    title: ListItemData.name
                    subtitle: ListItemData.hadith_number
                }
                
                Label {
                    id: bodyLabel
                    content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                    multiline: true
                    text: ListItemData.body
                }
                
                contextActions: [
                    ActionSet
                    {
                        title: ListItemData.name
                        subtitle: ListItemData.hadith_number
                        
                        MultiSelectActionItem
                        {
                            id: msa
                            imageSource: "images/menu/ic_more_items.png"
                            
                            onTriggered: {
                                narrationRoot.ListItem.view.multiSelectHandler.active = true;
                            }
                        }
                        
                        DeleteActionItem
                        {
                            imageSource: "images/menu/ic_unlink_narration.png"
                            title: qsTr("Unlink") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: UnlinkNarrationFromSuitePage");
                                narration.ListItem.view.unlinkNarration(narration.ListItem);
                            }
                        }
                    }
                ]
            }
        },
        
        ListItemComponent
        {
            type: "question"
            
            QuestionListItem {}
        }
    ]
}