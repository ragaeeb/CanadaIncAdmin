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
        questionsPage.loadAll();
    }
    
    QuestionPickerPage
    {
        id: questionsPage
        
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
            
            popToRoot();
        }
        
        onOpenSuitePage: {
            definition.source = "CreateSuitePage.qml";
            var page = definition.createObject();
            page.suitePageId = suitePageId;
            navigationPane.push(page);
        }
        
        onPicked: {
            definition.source = "CreateQuestionPage.qml";
            var page = definition.createObject();
            page.questionId = questionId;
            page.saveQuestion.connect(onQuestionSaved);
            navigationPane.push(page);
        }
    }
    
    attachedObjects: [
        ComponentDefinition {
            id: definition
        }
    ]
}