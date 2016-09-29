import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: narrationPage
    function cleanUp() {}
    property int chapter
    property int fromVerse
    property int toVerse
    
    actions: [
        DeleteActionItem
        {
            id: clearAll
            imageSource: "images/menu/ic_reset_search.png"
            title: qsTr("Clear") + Retranslate.onLanguageChanged
            
            onTriggered: {
                tftk.textField.resetText();
                tftk.textField.requestFocus();
            }
        }
    ]
    
    function load()
    {
        tftk.textField.text = fromVerse != toVerse ? "%1:%2-%3".arg(chapter).arg(fromVerse).arg(toVerse) : "%1:%2".arg(chapter).arg(fromVerse);
        quran.fetchExplanationsFor(narrationPage, chapter, fromVerse, toVerse);
    }
    
    function focus() {
        timer.start();
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchExplanationsFor)
        {
            adm.clear()
            adm.append(data);
        }
    }
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            textField.hintText: qsTr("Ayat number...") + Retranslate.onLanguageChanged
            textField.input.submitKey: SubmitKey.Submit
            textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.input.onSubmitted: {
                var inputted = tftk.textField.text.trim();
                var tokens = inputted.split(":");
                var c = parseInt(tokens[0]);
                
                if (c > 0 && c <= 114)
                {
                    var f = 0;
                    var t = 0;
                    
                    if (tokens.length > 1)
                    {
                        tokens = tokens[1].split("-");
                        
                        f = parseInt(tokens[0]);
                        
                        if (tokens.length > 1) {
                            t = parseInt(tokens[1]);
                        } else {
                            t = f;
                        }
                    }
                    
                    if (c != chapter || f != fromVerse || t != toVerse)
                    {
                        chapter = c;
                        fromVerse = f;
                        toVerse = t;
                        load();
                    }
                }
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        ListView
        {
            id: listView
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        title: ListItemData.author
                        description: ListItemData.heading && ListItemData.heading.length > 0 ? ListItemData.heading : ListItemData.title
                        imageSource: "images/list/ic_unique_narration.png"
                    }
                }
            ]
            
            onTriggered: {
                var element = dataModel.data(indexPath);
                
                var page = Qt.launch("TafsirContentsPage.qml");
                page.title = element.title;
                
                var searchData = {'suitePageId': element.id};
                page.searchData = searchData;

                page.suiteId = element.suite_id;
            }
        }
    }
    
    attachedObjects: [
        Timer {
            id: timer
            running: false
            interval: 150
            
            onTriggered: {
                tftk.textField.requestFocus();
            }
        }
    ]
}