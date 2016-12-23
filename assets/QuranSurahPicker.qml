import QtQuick 1.0
import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: narrationPage
    property variant chapters: quran.chapters()
    property int chapter
    property int fromVerse
    property int toVerse
    function cleanUp() {}
    signal picked(int chapter, int verse)
    
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
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            textField.hintText: qsTr("Search surah name") + Retranslate.onLanguageChanged
            textField.input.submitKey: SubmitKey.Search
            textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.onTextChanging: {
                var textValue = tftk.textField.text.trim().toLowerCase();
                var matches = [];
                
                if (textValue.length > 1)
                {
                    for (var i = 0; i < chapters.length; i++)
                    {
                        var current = chapters[i];

                        if ( current.toLowerCase().indexOf(textValue) > -1 ) {
                            matches.push({'surah_id': i+1, 'name': current})
                        }
                    }
                } else if (textValue.length == 0) {
                    for (var i = 0; i < chapters.length; i++)
                    {
                        var current = chapters[i];
                        matches.push({'surah_id': i+1, 'name': current})
                    }
                }
                
                adm.clear();
                adm.append(matches);
            }
            
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
    
    ListView
    {
        id: listView
        objectName: "listView"
        scrollRole: ScrollRole.Main
        
        dataModel: ArrayDataModel {
            id: adm
        }
        
        listItemComponents: [
            ListItemComponent
            {
                type: "surah"
                
                StandardListItem
                {
                    id: sli
                    title: ListItemData.name
                    status: ListItemData.surah_id
                }
            },
            
            ListItemComponent
            {
                type: "page"
                
                StandardListItem
                {
                    title: ListItemData.author
                    description: ListItemData.heading && ListItemData.heading.length > 0 ? ListItemData.heading : ListItemData.title
                    imageSource: "images/list/ic_unique_narration.png"
                }
            }
        ]
        
        function itemType(data, indexPath)
        {
            if (data.surah_id) {
                return "surah";
            } else {
                return "page";
            }
        }
        
        onTriggered: {
            var data = dataModel.data(indexPath);
            
            if ( itemType(data, indexPath) == "page" )
            {
                var page = Qt.launch("TafsirContentsPage.qml");
                page.title = data.title;
                
                var searchData = {'suitePageId': data.id};
                page.searchData = searchData;
                page.suiteId = data.suite_id;
            } else {
                picked(data.surah_id, 0);
            }
        }
    }
    
    attachedObjects: [
        Timer {
            id: timer
            interval: 150
            repeat: false
            running: false
            
            onTriggered: {
                tftk.textField.textChanging("");
                tftk.textField.requestFocus();
            }
        }
    ]
}