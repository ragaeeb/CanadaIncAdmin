import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: createPage
    property variant questionId
    signal saveQuestion(variant id, string standardBody, string orderedBody, string countBody, string afterBody, string beforeBody, int difficulty)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    function cleanUp() {}
    
    onQuestionIdChanged: {
        if (questionId) {
            ilmTest.fetchQuestionsForSuitePage(createPage, questionId);
        }
    }
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchQuestionsForSuitePage && results.length > 0)
        {
            var data = results[0];
            
            if (data.standard_body) {
                tftk.textField.text = data.standard_body.toString();
            }
            
            if (data.ordered_body) {
                orderedBody.text = data.ordered_body.toString();
            }
            
            if (data.count_body) {
                countBody.text = data.count_body.toString();
            }
            
            if (data.before_body) {
                beforeBody.text = data.before_body.toString();
            }
            
            if (data.after_body) {
                afterBody.text = data.after_body.toString();
            }
            
            if (data.difficulty) {
                difficulty.text = data.difficulty.toString();
            }
        }
    }
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            
            textField {
                hintText: qsTr("Standard Body...") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                input.keyLayout: KeyLayout.Text
                inputMode: TextFieldInputMode.Text
                input.submitKey: SubmitKey.Next
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                
                validator: Validator
                {
                    errorMessage: qsTr("Invalid question") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: { 
                        valid = tftk.textField.text.trim().length > 10;
                    }
                }
            }
        }
        
        dismissAction: ActionItem
        {
            id: saveAction
            imageSource: "images/dropdown/ic_save_question.png"
            title: qsTr("Save") + Retranslate.onLanguageChanged
            
            onTriggered: {
                console.log("UserEvent: SaveQuestion");
                
                tftk.textField.validator.validate();
                difficulty.validator.validate();

                if ( !orderedBody.validate() ) {
                    return;
                }
                
                if ( !countBody.validate() ) {
                    return;
                }
                
                if ( !beforeBody.validate() ) {
                    return;
                }
                
                if ( !afterBody.validate() ) {
                    return;
                }
                
                if (tftk.textField.validator.valid && difficulty.validator.valid) {
                    saveQuestion(questionId, tftk.textField.text.trim(), orderedBody.text.trim(), countBody.text.trim(), afterBody.text.trim(), beforeBody.text.trim(), parseInt( difficulty.text.trim() ) );
                }
            }
        }
    }
    
    ScrollView
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            topPadding: 10
            
            ToggleTextArea {
                id: orderedBody
                hintText: qsTr("Ordered Body") + Retranslate.onLanguageChanged
                name: "OrderedBody"
            }
            
            ToggleTextArea {
                id: countBody
                hintText: qsTr("Count Body") + Retranslate.onLanguageChanged
                name: "CountBody"
            }
            
            ToggleTextArea {
                id: beforeBody
                hintText: qsTr("Before Body") + Retranslate.onLanguageChanged
                name: "BeforeBody"
            }
            
            ToggleTextArea
            {
                id: afterBody
                hintText: qsTr("After Body") + Retranslate.onLanguageChanged
                name: "AfterBody"
            }
            
            TextField
            {
                id: difficulty
                hintText: qsTr("Difficulty Level") + Retranslate.onLanguageChanged
                content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                input.keyLayout: KeyLayout.Number
                inputMode: TextFieldInputMode.NumbersAndPunctuation
                
                validator: Validator
                {
                    mode: ValidationMode.FocusLost
                    errorMessage: qsTr("Invalid Difficulty Level") + Retranslate.onLanguageChanged
                    
                    onValidate: {
                        valid = difficulty.text.trim().length == 0 || difficulty.text.trim().match("\\d+$");
                    }
                }
            }
        }
    }
}