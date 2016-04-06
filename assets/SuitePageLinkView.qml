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
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_birth_city.png"
                            title: qsTr("Birth City") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CreateBirthCityQuestion");
                                bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("Where was %1 born?"), qsTr("%1 was born in %2."), qsTr("Was %1 was born in %2?") );
                            }
                        }
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_death_age.png"
                            title: qsTr("Death Age") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CreateDeathAgeQuestion");
                                bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("How old was %1 (رحمه الله) when he passed away?"), qsTr("%1 (رحمه الله) was %2 when he passed away."), qsTr("Was %1 (رحمه الله) %2 when he passed away?") );
                            }
                        }
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_masters_univ.png"
                            title: qsTr("Masters University") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CreateMastersUnivQuestion");
                                bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What university did %1 complete his Masters Degree in?"), qsTr("%1 completed his Masters Degree in %2."), qsTr("Did %1 complete his Masters Degree in %2?") );
                            }
                        }
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_masters_year.png"
                            title: qsTr("Masters Year") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CreateMastersYearQuestion");
                                bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What year did %1 complete his Masters Degree?"), qsTr("%1 completed his Masters Degree in %2 AH."), qsTr("Did %1 complete his Masters Degree in %2 AH?") );
                            }
                        }
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_phd_univ.png"
                            title: qsTr("PhD University") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CreatePhDUnivQuestion");
                                bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What university did %1 complete his PhD in?"), qsTr("%1 completed his PhD in %2."), qsTr("Did %1 complete his PhD in %2?") );
                            }
                        }
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_phd_year.png"
                            title: qsTr("PhD Year") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CreatePhDYearQuestion");
                                bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What year did %1 complete his PhD?"), qsTr("%1 completed his PhD in %2 AH."), qsTr("Did %1 complete his PhD in %2 AH?") );
                            }
                        }
                        
                        ActionItem
                        {
                            imageSource: "images/menu/ic_tribe.png"
                            title: qsTr("Tribe") + Retranslate.onLanguageChanged
                            
                            onTriggered: {
                                console.log("UserEvent: CreateTribeQuestion");
                                bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What tribe was %1 from?"), qsTr("%1 was from the tribe of %2."), qsTr("Was %1 from the tribe of %2?") );
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
            type: "narration"
            
            StandardListItem
            {
                id: narration
                description: ListItemData.body
                imageSource: "images/list/ic_narration.png"
                title: ListItemData.collection_name
                status: ListItemData.hadith_number
                
                contextActions: [
                    ActionSet
                    {
                        title: narration.title
                        subtitle: narration.status
                        
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