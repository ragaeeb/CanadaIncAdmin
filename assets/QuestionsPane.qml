import bb.cascades 1.3
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    function popToRoot()
    {
        while (navigationPane.top != questionsPage) {
            navigationPane.pop();
        }
    }
    
    onCreationCompleted: {
        tftk.textField.input.submitted(undefined);
    }
    
    Page
    {
        id: questionsPage
        actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
        
        titleBar: TitleBar
        {
            kind: TitleBarKind.TextField
            kindProperties: TextFieldTitleBarKindProperties
            {
                id: tftk
                textField.hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
                textField.input.submitKey: SubmitKey.Search
                textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                textField.input.onSubmitted: {
                    busy.delegateActive = true;
                    
                    var query = textField.text.trim();
                    ilmTest.fetchAllQuestions(listView, query);
                }
                
                onCreationCompleted: {
                    textField.input["keyLayout"] = 7;
                }
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_choices.png"
                labelText: qsTr("No results found for your query. Try another query.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    tftk.textField.requestFocus();
                }
            }
            
            ListView
            {
                id: listView
                scrollRole: ScrollRole.Main
                property variant editIndexPath
                
                dataModel: ArrayDataModel {
                    id: adm
                }
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.FetchAllQuestions)
                    {
                        adm.clear();
                        adm.append(data);
                        busy.delegateActive = false;
                    } else if (id == QueryId.EditQuestion) {
                        persist.showToast( qsTr("Question updated"), "images/toast/ic_question_edited.png" );
                        busy.delegateActive = false;
                    } else if (id == QueryId.RemoveQuestion) {
                        persist.showToast( qsTr("Question removed!"), "images/menu/ic_remove_question.png" );
                        busy.delegateActive = false;
                    } else if (id == QueryId.UpdateSortOrder) {
                        persist.showToast( qsTr("Sort order updated!"), "images/dropdown/save_bio.png" );
                        busy.delegateActive = false;
                    }
                    
                    listView.visible = !adm.isEmpty();
                    noElements.delegateActive = !listView.visible;
                }
                
                function removeQuestion(ListItem, ListItemData)
                {
                    busy.delegateActive = true;
                    ilmTest.removeQuestion(listView, ListItemData.id);
                    adm.removeAt(ListItem.indexPath[0]);
                }
                
                listItemComponents: [
                    ListItemComponent
                    {
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
                
                function onQuestionSaved(id, standardBody, standardNegation, boolStandard, promptStandard, orderedBody, countBody, boolCount, promptCount, afterBody, beforeBody, difficulty, choices)
                {
                    var edited = ilmTest.editQuestion(listView, id, standardBody, standardNegation, boolStandard, promptStandard, orderedBody, countBody, boolCount, promptCount, afterBody, beforeBody, difficulty);
                    adm.replace(editIndexPath[0], edited);
                    
                    if (choices.length > 0 && orderedBody.length > 0) {
                        ilmTest.updateSortOrders(listView, choices);
                    }
                    
                    popToRoot();
                }
                
                onTriggered: {
                    console.log("UserEvent: QuestionTriggered");
                    
                    var d = dataModel.data(indexPath);
                    definition.source = "CreateQuestionPage.qml";
                    var page = definition.createObject();
                    page.questionId = d.source_id ? d.source_id : d.id;
                    page.saveQuestion.connect(onQuestionSaved);
                    editIndexPath = indexPath;
                    navigationPane.push(page);
                }
            }
            
            ProgressControl
            {
                id: busy
                asset: "images/progress/loading_suite_ayats.png"
            }
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}