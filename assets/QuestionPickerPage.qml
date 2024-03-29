import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: questionsPage
    property alias questionsModel: adm
    property alias questionsList: listView
    signal picked(variant questionId, variant sourceId, string value)
    signal openSuitePage(variant suitePageId)
    signal orderChanged()
    signal totalLoaded(int size)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    function cleanUp() {}
    
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
    
    function loadAll() {
        tftk.textField.input.submitted(undefined);
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
        
        OrderedListView
        {
            id: listView
            scrollRole: ScrollRole.Main
            
            rearrangeHandler.onMoveUpdated: {
                orderChanged();
            }
            
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
                    totalLoaded(data.length);
                } else if (id == QueryId.EditQuestion) {
                    persist.showToast( qsTr("Question updated"), "images/toast/question_updated.png" );
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
                rearrangeHandler.active = true;
            }
            
            function viewSource(ListItem, ListItemData) {
                openSuitePage(ListItemData.suite_page_id);
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
                    Container
                    {
                        id: qsli
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        Header {
                            title: ListItemData.difficulty ? ListItemData.difficulty.toString() : ListItemData.id.toString()
                        }
                        
                        Container
                        {
                            leftPadding: 10; rightPadding: 10; bottomPadding: 5; topPadding: 5
                            horizontalAlignment: HorizontalAlignment.Fill
                            
                            Label {
                                id: bodyLabel
                                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                                multiline: true
                                text: ListItemData.standard_body
                            }
                        }
                        
                        contextActions: [
                            ActionSet
                            {
                                title: qsli.title
                                subtitle: qsli.status
                                
                                ActionItem
                                {
                                    imageSource: "images/ic_percent.png"
                                    title: qsTr("View Source") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: ViewSource");
                                        qsli.ListItem.view.viewSource(qsli.ListItem, ListItemData);
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
            
            onTriggered: {
                console.log("UserEvent: QuestionPicked");
                
                var d = dataModel.data(indexPath);
                picked(d.id, d.source_id, d.standard_body)
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_suite_ayats.png"
        }
    }
}