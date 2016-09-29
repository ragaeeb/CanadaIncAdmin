import bb.cascades 1.3
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    onCreationCompleted: {
        questionsPage.loadAll();
    }
    
    QuestionPickerPage
    {
        id: questionsPage
        
        onTotalLoaded: {
            navigationPane.parent.unreadContentCount = size;
        }
        
        actions: [
            ActionItem
            {
                id: commitChanges
                ActionBar.placement: ActionBarPlacement.Signature
                enabled: false
                imageSource: "images/menu/ic_merge_into.png"
                title: qsTr("Commit") + Retranslate.onLanguageChanged
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.UpdateSortOrder) {
                        persist.showToast( qsTr("Question difficulties updated!"), imageSource.toString() );
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: CommitQuestions");
                    ilmTest.updateQuestionOrders( commitChanges, global.extractADM(questionsPage.questionsModel) );
                }
            }
        ]
        
        onOrderChanged: {
            commitChanges.enabled = true;
        }
        
        function onQuestionSaved(id, standardBody, standardNegation, boolStandard, promptStandard, orderedBody, countBody, boolCount, promptCount, afterBody, beforeBody, difficulty, choices, sourceId)
        {
            var edited = ilmTest.editQuestion(questionsList, id, standardBody, standardNegation, boolStandard, promptStandard, orderedBody, countBody, boolCount, promptCount, afterBody, beforeBody, difficulty, sourceId);
            
            for (var i = questionsModel.size()-1; i >= 0; i--)
            {
                if ( questionsModel.value(i).id == id )
                {
                    questionsModel.replace(i, edited);
                    break;
                }
            }
            
            if (choices.length > 0 && orderedBody.length > 0) {
                ilmTest.updateSortOrders(questionsList, choices);
            }
            
            Qt.popToRoot(questionsPage);
        }
        
        onOpenSuitePage: {
            var page = Qt.launch("CreateSuitePage.qml");
            page.suitePageId = suitePageId;
        }
        
        onPicked: {
            var page = Qt.launch("CreateQuestionPage.qml")
            page.questionId = questionId;
            page.saveQuestion.connect(onQuestionSaved);
        }
    }
}