import QtQuick 1.0
import bb.cascades 1.3
import bb.system 1.2
import com.canadainc.data 1.0

Page
{
    id: createPage
    property variant questionId
    property variant sourceId
    signal saveQuestion(variant id, string standardBody, string standardNegation, string boolStandard, string promptStandard, string orderedBody, string countBody, string boolCount, string promptCount, string afterBody, string beforeBody, int difficulty, variant choices, variant sourceId)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onQuestionIdChanged: {
        if (questionId) {
            ilmTest.fetchQuestion(createPage, questionId);
            ilmTest.fetchChoicesForQuestion(createPage, questionId);
        }
    }
    
    onSourceIdChanged: {
        if (sourceId) {
            ilmTest.fetchQuestion(createPage, sourceId);
            sourceIdField.text = sourceId.toString();
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
                input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
                input.keyLayout: KeyLayout.Text
                inputMode: TextFieldInputMode.Text
                input.submitKey: SubmitKey.Next
                input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Next
                
                onFocusedChanged: {
                    if (!focused && !questionId && !sourceId && boolStandardBody.text.length == 0 && promptStandardBody.text.length == 0 && tftk.textField.text.length > 0)
                    {
                        var toCopy = tftk.textField.text;
                        boolStandardBody.text = toCopy.charAt(toCopy.length-1) == '?' ? toCopy.substring(0, toCopy.length-1) + "." : toCopy;
                        promptStandardBody.text = toCopy;
                    }
                }
                
                validator: Validator
                {
                    errorMessage: qsTr("Invalid question") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: { 
                        valid = tftk.textField.text.trim().length > 10;
                    }
                }
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: DoubleTappedStandardBody");
                            tftk.textField.text = tftk.textField.text + global.getCapitalizedClipboard();
                        }
                    }
                ]
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
                
                if (tftk.textField.validator.valid && difficulty.validator.valid) {
                    saveQuestion(questionId, tftk.textField.text.trim(), standardBodyNegation.text.trim(), boolStandardBody.text.trim(), promptStandardBody.text.trim(), orderedBody.text.trim(), countBody.text.trim(), boolCountBody.text.trim(), promptCountBody.text.trim(), afterBody.text.trim(), beforeBody.text.trim(), parseInt( difficulty.text.trim() ), global.extractADM(adm), sourceIdField.text.trim() );
                }
            }
        }
    }
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchQuestion && results.length > 0)
        {
            var data = results[0];
            
            if (data.standard_body) {
                tftk.textField.text = data.standard_body.toString();
            }
            
            if (data.bool_standard_body) {
                boolStandardBody.text = data.bool_standard_body.toString();
            }
            
            if (data.prompt_standard_body) {
                promptStandardBody.text = data.prompt_standard_body.toString();
            }
            
            if (data.ordered_body) {
                orderedBody.text = data.ordered_body.toString();
            }
            
            if (data.count_body) {
                countBody.text = data.count_body.toString();
            }
            
            if (data.bool_count_body) {
                boolCountBody.text = data.bool_count_body.toString();
            }
            
            if (data.prompt_count_body) {
                promptCountBody.text = data.prompt_count_body.toString();
            }
            
            if (data.before_body) {
                beforeBody.text = data.before_body.toString();
            }
            
            if (data.after_body) {
                afterBody.text = data.after_body.toString();
            }
            
            if (data.standard_negation_body) {
                standardBodyNegation.text = data.standard_negation_body.toString();
            }
            
            if (data.difficulty) {
                difficulty.text = data.difficulty.toString();
            }
            
            if (data.source_id) {
                sourceIdField.text = data.source_id.toString();
            }
        } else if (id == QueryId.FetchChoicesForQuestion) {
            adm.clear();
            adm.append(results);
            listView.refresh();
        } else if (id == QueryId.RemoveAnswer) {
            persist.showToast( qsTr("Answer removed!"), "images/menu/ic_remove_answer.png" );
        }
    }
    
    actions: [
        ActionItem
        {
            enabled: questionId > 0
            imageSource: "images/menu/ic_add_choice.png"
            title: qsTr("Add Choice") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            function process(choiceId, value, yes)
            {
                var element = ilmTest.addAnswer(questionId, choiceId, yes);
                element.value_text = value;
                
                adm.append(element);
            }
            
            function scrollAndRefresh()
            {
                navigationPane.pop();
                listView.scrollToPosition(ScrollPosition.End, ScrollAnimation.Smooth);
                listView.refresh();
            }
            
            function onPicked(choiceId, value)
            {
                var yes = persist.showBlockingDialog( qsTr("Correct?"), qsTr("Is this a correct answer?") );
                process(choiceId, value, yes);
                
                scrollAndRefresh();
            }
            
            function onPickedMulti(values)
            {
                var yes = persist.showBlockingDialog( qsTr("Correct?"), qsTr("Is this a correct answer?") );
                
                for (var i = values.length-1; i >= 0; i--)
                {
                    var current = values[i];
                    process(current.id, current.value_text, yes);
                }

                scrollAndRefresh();
            }
            
            onTriggered: {
                console.log("UserEvent: AddChoice");
                definition.source = "ChoicePickerPage.qml";
                var picker = definition.createObject();
                picker.picked.connect(onPicked);
                picker.pickedMulti.connect(onPickedMulti);
                navigationPane.push(picker);
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.Search
                }
            ]
        }
    ]
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        topPadding: 10
        
        ScrollView
        {
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                ToggleTextArea
                {
                    id: boolStandardBody
                    hintText: qsTr("Bool Standard Body (ie: X is one of the pillars of eemaan.)") + Retranslate.onLanguageChanged
                    name: "BoolStandardBody"
                    visible: standardBodyNegation.visible
                }
                
                ToggleTextArea
                {
                    id: promptStandardBody
                    hintText: qsTr("Prompt Standard Body (ie: Is X one of the pillars of eemaan?)") + Retranslate.onLanguageChanged
                    name: "PromptStandardBody"
                    visible: boolStandardBody.visible
                }
                
                ToggleTextArea
                {
                    id: afterBody
                    hintText: qsTr("After Body (Which pillar of eemaan comes after Belief in Allah?)") + Retranslate.onLanguageChanged
                    name: "AfterBody"
                    visible: orderedBody.text.length > 0
                }
                
                ToggleTextArea {
                    id: beforeBody
                    hintText: qsTr("Before Body (Which pillar of eemaan comes before Belief in the Angels?)") + Retranslate.onLanguageChanged
                    name: "BeforeBody"
                    visible: afterBody.visible
                }
                
                ToggleTextArea {
                    id: countBody
                    hintText: qsTr("Count Body (ie: How many pillars of eemaan are there?)") + Retranslate.onLanguageChanged
                    name: "CountBody"
                }
                
                ToggleTextArea
                {
                    id: boolCountBody
                    hintText: qsTr("Bool Count Body (ie: There are X pillars of eemaan.)") + Retranslate.onLanguageChanged
                    name: "BoolCountBody"
                    visible: countBody.visible
                }
                
                ToggleTextArea
                {
                    id: promptCountBody
                    hintText: qsTr("Prompt Count Body (ie: Are there X pillars of eemaan?)") + Retranslate.onLanguageChanged
                    name: "PromptCountBody"
                    visible: countBody.visible
                }
                
                ToggleTextArea {
                    id: orderedBody
                    hintText: qsTr("Ordered Body (ie: Rearrange the pillars of faith in order.)") + Retranslate.onLanguageChanged
                    name: "OrderedBody"
                    
                    onTextChanged: {
                        listView.refresh();
                    }
                }
                
                ToggleTextArea
                {
                    id: standardBodyNegation
                    hintText: qsTr("Standard Body Negation (ie: Which of the following are NOT pillars of eemaan?)") + Retranslate.onLanguageChanged
                    name: "StandardBodyNegation"
                    visible: tftk.textField.text.length > 0
                }
                
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    
                    layout: StackLayout {
                        orientation: LayoutOrientation.LeftToRight
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
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 0.5
                        }
                    }
                    
                    TextField
                    {
                        id: sourceIdField
                        hintText: qsTr("Source Question") + Retranslate.onLanguageChanged
                        content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                        input.flags: TextInputFlag.SpellCheckOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                        input.keyLayout: KeyLayout.Number
                        inputMode: TextFieldInputMode.NumbersAndPunctuation
                        
                        validator: Validator
                        {
                            mode: ValidationMode.FocusLost
                            errorMessage: qsTr("Invalid source question") + Retranslate.onLanguageChanged
                            
                            onValidate: {
                                valid = sourceIdField.text.trim().length == 0 || sourceIdField.text.trim().match("\\d+$");
                            }
                        }
                        
                        layoutProperties: StackLayoutProperties {
                            spaceQuota: 0.5
                        }
                    }
                }
                
                layoutProperties: StackLayoutProperties {
                    id: slp
                    spaceQuota: 0.5
                }
            }
        }
        
        Divider {
            topMargin: 0; bottomMargin: 0
        }
        
        OrderedListView
        {
            id: listView
            scrollRole: ScrollRole.Main
            visible: questionId > 0
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function refresh()
            {
                rearrangeHandler.active = false;
                
                if ( orderedBody.text.trim().length > 0 ) {
                    rearrangeHandler.active = true;
                }
                
                visible = !adm.isEmpty();
            }
            
            function removeAnswer(ListItem, ListItemData)
            {
                ilmTest.removeAnswer(createPage, ListItemData.id);
                adm.removeAt(ListItem.indexPath[0]);
                
                refresh();
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        id: sli
                        imageSource: ListItemData.correct == 1 ? "images/list/ic_answer_correct.png" : "images/list/ic_answer_incorrect.png"
                        title: ListItemData.value_text
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sli.title
                                subtitle: sli.status
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_answer.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveAnswer");
                                        sli.ListItem.view.removeAnswer(sli.ListItem, ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
        }
    }
    
    function cleanUp() {}
    
    attachedObjects: [
        Timer
        {
            repeat: false
            running: true
            interval: 100
            
            onTriggered: {
                if (deviceUtils.isPhysicalKeyboardDevice) {
                    tftk.textField.requestFocus();
                }
            }
        }
    ]
}