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
        if (id == QueryId.FetchAyatsForTafsir || id == QueryId.FetchNarrationsForSuitePage || id == QueryId.FetchBioMetadata || id == QueryId.FetchQuestionsForSuitePage || id == QueryId.FetchTagsForSuitePage)
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
        } else if (id == QueryId.EditTag) {
            persist.showToast( qsTr("Tag updated!"), "images/toast/edited_tags.png" );
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
        } else if (id == QueryId.RemoveTag) {
            persist.showToast( qsTr("Tag removed!"), "images/menu/ic_remove_tag.png" );
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
            definition.source = "NarrationProfilePage.qml";
            var page = definition.createObject();
            page.narrationId = d.narration_id;
            navigationPane.push(page);
        } else if (t == "tag") {
            var tag = persist.showBlockingPrompt( qsTr("Enter tag"), qsTr("Please enter a tag for this suite page"), "", qsTr("Enter value"), 50, true, qsTr("Save"), qsTr("Cancel") ).trim().toLowerCase();
            
            if (tag.length > 0)
            {
                var edited = salat.editTag(listView, d.id, tag);
                adm.replace(indexPath[0], edited);
            }
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
    
    function removeTag(ListItem)
    {
        busy.delegateActive = true;
        salat.removeTag(listView, ListItem.data.id);
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
        } else if (data.tag) {
            return "tag"
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
        },
        
        DeleteActionItem
        {
            imageSource: "images/menu/ic_unlink_narration.png"
            title: qsTr("Unlink") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: UnlinkNarrationsFromSuitePage");
                var all = listView.selectionList();
                var result = [];
                var i = 0;
                
                for (i = all.length-1; i >= 0; i--) {
                    result.push( listView.dataModel.data(all[i]).narration_id );
                }
                
                for (i = adm.size()-1; i >= 0; i--)
                {
                    if ( result.indexOf( adm.value(i).narration_id ) != -1 ) {
                        adm.removeAt(i);
                    }
                }

                busy.delegateActive = true;
                sunnah.unlinkNarrationsFromSuitePage(listView, result, suitePageId);
            }
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
                                narrationRoot.ListItem.view.unlinkNarration(narrationRoot.ListItem);
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
        },
        
        ListItemComponent
        {
            type: "tag"
            
            StandardListItem
            {
                id: tagRoot
                imageSource: "images/list/ic_tag.png"
                title: ListItemData.tag
                
                contextActions: [
                    ActionSet
                    {
                        title: tagRoot.title
                        
                        DeleteActionItem
                        {
                            imageSource: "images/menu/ic_remove_tag.png"
                            title: qsTr("Remove") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: RemoveTag");
                                tagRoot.ListItem.view.removeTag(tagRoot.ListItem);
                            }
                        }
                    }
                ]
            }
        }
    ]
}