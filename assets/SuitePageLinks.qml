import bb.cascades 1.0
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: narrationsPage
    property variant suitePageId
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property alias adm: listView.dataModel
    
    onSuitePageIdChanged: {
        if (suitePageId)
        {
            quran.fetchAyatsForTafsir(listView, suitePageId);
            ilmHelper.fetchBioMetadata(listView, suitePageId);
            ilmTest.fetchQuestionsForSuitePage(listView, suitePageId);
            sunnah.fetchNarrationsForSuitePage(listView, suitePageId);
            salat.fetchTagsForSuitePage(listView, suitePageId);
        }
    }
    
    function onFinished(message, cookie)
    {
        var tokens = message.split("/");
        var surahId = parseInt( tokens[0] );
        var verseId = parseInt( tokens[1] );

        if (cookie == "searchPicked") {
            searchAction.onPicked(surahId, verseId);
        } else if (cookie == "ayatPicked" || cookie == "surahPicked") {
            lookupAction.onPicked(surahId, verseId);
        }
    }

    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(narrationsPage, listView);

        bioTypeDialog.add( qsTr("Jarh"), -1 );
        bioTypeDialog.add( qsTr("Biography"), 2 );
        bioTypeDialog.add( qsTr("Tahdeel"), 1 );
        bioTypeDialog.add( qsTr("Cited"), 0, true );
        bioTypeDialog.add( qsTr("Translator"), 3 );
        bioTypeDialog.add( qsTr("Narrator"), 4 );
    }

    actions: [
        ActionItem
        {
            id: addAction
            imageSource: "images/menu/ic_link_ayat_to_tafsir.png"
            title: qsTr("Link Ayat") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: TafsirAyatAddTriggered");
                prompt.inputField.resetDefaultText();
                prompt.resetIndexPath();
                prompt.show();
            }
        },
        
        ActionItem
        {
            id: addNarration
            imageSource: "images/menu/ic_add_narration.png"
            title: qsTr("Add Narration") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            function onPicked(elements)
            {
                var all = [];
                
                for (var i = elements.length-1; i >= 0; i--) {
                    all.push(elements[i].narration_id);
                }
                
                sunnah.linkNarrationsToSuitePage(listView, suitePageId, all);
                
                if ( persist.getValueFor("promptSimilar") == 1 ) {
                    sunnah.fetchSimilarNarrations(listView, all);
                }

                Qt.popToRoot(narrationsPage);
            }
            
            shortcuts: [
                Shortcut {
                    key: qsTr("H") + Retranslate.onLanguageChanged
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: AddNarration");
                var c = Qt.launch("NarrationPickerPage.qml")
                c.picked.connect(onPicked);
            }
        },
        
        ActionItem
        {
            id: addQuestion
            imageSource: "images/menu/ic_add_question.png"
            title: qsTr("Add Question") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.InOverflow
            
            function onQuestionSaved(id, standardBody, standardNegation, boolStandard, promptStandard, orderedBody, countBody, boolCount, promptCount, afterBody, beforeBody, difficulty, choices, sourceId)
            {
                var result = ilmTest.addQuestion(suitePageId, standardBody, standardNegation, boolStandard, promptStandard, orderedBody, countBody, boolCount, promptCount, afterBody, beforeBody, difficulty, sourceId);
                adm.insert(0, result);
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                listView.visible = !adm.isEmpty();
                noElements.delegateActive = !listView.visible;
                
                Qt.popToRoot(narrationsPage);
                
                persist.showToast( qsTr("Question added!"), "images/menu/ic_add_question.png" );
                
                listView.triggered([0]);
            }
            
            onTriggered: {
                console.log("UserEvent: AddQuestion");

                var page = Qt.launch("CreateQuestionPage.qml");
                page.saveQuestion.connect(onQuestionSaved);
            }
            
            shortcuts: [
                Shortcut {
                    key: qsTr("Q") + Retranslate.onLanguageChanged
                }
            ]
        },
        
        ActionItem
        {
            id: searchAction
            imageSource: "images/menu/ic_search_choices.png"
            title: qsTr("Qur'an Search") + Retranslate.onLanguageChanged
            
            function onPicked(chapter, verse)
            {
                prompt.inputField.defaultText = chapter+":"+verse;
                prompt.show();
            }
            
            onCreationCompleted: {
                app.childCardFinished.connect(onFinished);
            }
            
            onTriggered: {
                console.log("UserEvent: SearchForText");
                persist.invoke("com.canadainc.Quran10.search.picker", "searchPicked");
            }
        },
        
        ActionItem
        {
            id: tagSuitePage
            imageSource: "images/menu/ic_add_tag.png"
            title: qsTr("Tag") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            function onPicked(tagObj)
            {
                var tagValue = tagObj.tag;
                
                var result = salat.tagSuitePage(suitePageId, tagValue);
                persist.showToast( qsTr("Tagged page as '%1'").arg(tagValue), imageSource.toString() );

                adm.insert(0, result);
                listView.scrollToPosition(ScrollPosition.Beginning, ScrollAnimation.Smooth);
                
                Qt.popToRoot(narrationsPage);
                
                listView.visible = !adm.isEmpty();
                noElements.delegateActive = !listView.visible;
            }
            
            onTriggered: {
                console.log("UserEvent: AddTag");
                var p = Qt.launch("TagPickerPage.qml");
                p.picked.connect(onPicked);
            }
            
            shortcuts: [
                Shortcut {
                    key: qsTr("G") + Retranslate.onLanguageChanged
                }
            ]
        },
        
        ActionItem
        {
            id: extractAyats
            imageSource: "images/menu/ic_capture_ayats.png"
            title: qsTr("Capture Ayats") + Retranslate.onLanguageChanged
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchTafsirContent)
                {
                    if (data.length > 0) {
                        quran.captureAyats(data[0].body);
                    } else {
                        busy.delegateActive = false;
                    }
                }
            }
            
            onTriggered: {
                console.log("UserEvent: ExtractHeadings");
                busy.delegateActive = true;
                tafsirHelper.fetchTafsirContent(extractAyats, suitePageId);
            }
            
            function onCaptured(all)
            {
                if (all && all.length > 0) {
                    quran.linkAyatsToTafsir(listView, suitePageId, all);
                    busy.delegateActive = true;
                } else {
                    persist.showToast( qsTr("No ayat signatures found..."), "images/menu/ic_capture_ayats.png" );
                    busy.delegateActive = false;
                }
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
            
            onCreationCompleted: {
                quran.ayatsCaptured.connect(onCaptured);
            }
        },
        
        ActionItem {
            imageSource: "images/tabs/ic_utils.png"
            title: qsTr("Fix Citings") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: FixCitings");
                
                var adm = listView.dataModel;
                
                for (var i = adm.size()-1; i >= 0; i--)
                {
                    var current = adm.value(i);
                    var indexPath = [i];
                    
                    if ( listView.itemType(current, indexPath) == "bio" && (!current.points || current.points == 2) )
                    {
                        if (!current.points) {
                            current.points = 2;
                        } else if (current.points == 2) {
                            delete current.points;
                        }
                        
                        adm.replace(indexPath, current);
                        ilmHelper.editMention(listView, current.id, current.points);
                    }
                }
            }
        }
    ]
    
    function cleanUp() {
        quran.ayatsCaptured.disconnect(extractAyats.onCaptured);
        app.childCardFinished.disconnect(onFinished);
    }
    
    titleBar: TitleBar
    {
        scrollBehavior: TitleBarScrollBehavior.NonSticky
        title: qsTr("Links") + Retranslate.onLanguageChanged
        
        dismissAction: ActionItem
        {
            id: addLink
            imageSource: "images/menu/ic_add_bio.png"
            title: qsTr("Mention") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            function onPicked(individualId, name)
            {
                ilmHelper.addMention(listView, suitePageId, [individualId], 0);
                
                bioTypeDialog.target = individualId;
                bioTypeDialog.finished(SystemUiResult.ConfirmButtonSelection);
                //bioTypeDialog.show();
                
                Qt.popToRoot(narrationsPage);
            }
            
            onTriggered: {
                console.log("UserEvent: AddLink");
                var c = Qt.launch("IndividualPickerPage.qml");
                c.picked.connect(onPicked);
                ilmHelper.fetchFrequentIndividuals(c.pickerList, "mentions", "target", 12);
            }
        }
        
        acceptAction: ActionItem
        {
			id: lookupAction
            imageSource: "images/dropdown/search_reference.png"
            title: qsTr("Surah") + Retranslate.onLanguageChanged
            
            function onPicked(chapter, verse)
            {
                if (verse > 0) {
                    prompt.inputField.defaultText = chapter+":"+verse;
                } else {
                    prompt.inputField.defaultText = chapter+":";
                }
                
                prompt.show();
            }
            
            onTriggered: {
                console.log("UserEvent: LookupChapter");
                var surahPicker = Qt.launch("QuranSurahPicker.qml");
                surahPicker.picked.connect(onPicked);
                surahPicker.focus();
                
                prompt.resetIndexPath();
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        SuitePageLinkView {
            id: listView
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_suite_ayats.png"
            labelText: qsTr("No links found. Tap on the Add button to add a new one.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                addAction.triggered();
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_suite_ayats.png"
        }
    }
    
    attachedObjects: [
        SystemPrompt
        {
            id: prompt
            property variant indexPath
            body: qsTr("Enter the chapter and verse associated with this tafsir:") + Retranslate.onLanguageChanged
            inputField.inputMode: SystemUiInputMode.NumbersAndPunctuation
            inputField.emptyText: qsTr("(ie: 2:4 for Surah Baqara verse #4)") + Retranslate.onLanguageChanged
            inputField.maximumLength: 12
            title: qsTr("Enter verse") + Retranslate.onLanguageChanged
            
            function resetIndexPath() {
                indexPath = undefined;
            }
            
            onFinished: {
                if (value == SystemUiResult.ConfirmButtonSelection)
                {
                    var inputted = inputFieldTextEntry().trim();
                    var tokens = inputted.split(":");
                    var chapter = parseInt(tokens[0]);
                    
                    if (chapter > 0)
                    {
                        var fromVerse = 0;
                        var toVerse = 0;
                        
                        if (tokens.length > 1)
                        {
                            tokens = tokens[1].split("-");
                            
                            fromVerse = parseInt(tokens[0]);
                            
                            if (tokens.length > 1) {
                                toVerse = parseInt(tokens[1]);
                            } else {
                                toVerse = fromVerse;
                            }
                        }
                        
                        if (indexPath)
                        {
                            var current = adm.data(indexPath);
                            current.surah_id = chapter;
                            current.from_verse_number = fromVerse;
                            current.to_verse_number = toVerse;
                            
                            quran.updateTafsirLink(listView, current.id, chapter, fromVerse, toVerse);
                            adm.replace(indexPath[0], current);
                        } else {
                            quran.linkAyatToTafsir(listView, suitePageId, chapter, fromVerse, toVerse);
                        }
                    } else {
                        persist.showToast( qsTr("Invalid entry specified. Please enter something with the Chapter:Verse scheme (ie: 2:55 for Surah Baqara vese #55)"), "images/toast/invalid_entry.png" );
                    }
                }
            }
        },
        
        SystemListDialog
        {
            id: bioTypeDialog
            property variant target
            property variant indexToPoints: []
            title: qsTr("Biography Type") + Retranslate.onLanguageChanged
            body: qsTr("Please select the type of biography this is:") + Retranslate.onLanguageChanged
            cancelButton.label: qsTr("Cancel")
            confirmButton.label: qsTr("OK") + Retranslate.onLanguageChanged
            
            function add(text, points, selected)
            {
                var i2p = indexToPoints;
                i2p.push(points);
                indexToPoints = i2p;
                appendItem(text, true, selected);
            }
            
            onFinished: {
                if (value == SystemUiResult.ConfirmButtonSelection)
                {
                    var selectedIndex = selectedIndices[0];
                    var points = indexToPoints[selectedIndex];
 
                    if (target) {
                        ilmHelper.addMention(listView, suitePageId, target instanceof Array ? target : [target], points);
                    } else {
                        var current = adm.data(prompt.indexPath);
                        current.points = points;
                        adm.replace(prompt.indexPath[0], current);
                        
                        ilmHelper.editMention(listView, current.id, points);
                    }
                }
            }
        }
    ]
}