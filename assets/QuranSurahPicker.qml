import QtQuick 1.0
import bb.cascades 1.3

Page
{
    property variant chapters: quran.chapters()
    function cleanUp() {}
    signal picked(int chapter, int verse)
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: textField
            textField.hintText: qsTr("Search surah name") + Retranslate.onLanguageChanged
            textField.input.submitKey: SubmitKey.Search
            
            textField.onTextChanging: {
                var textValue = textField.textField.text.trim();
                var matches = [];
                
                if (textValue.length > 1)
                {
                    for (var i = chapters.length-1; i >= 0; i--)
                    {
                        var current = chapters[i];
                        
                        if ( current.indexOf(textValue) > -1 ) {
                            matches.push({'surah_id': i+1, 'name': current})
                        }
                    }
                } else if (textValue.length == 0) {
                    for (var i = chapters.length-1; i >= 0; i--)
                    {
                        var current = chapters[i];
                        matches.push({'surah_id': i+1, 'name': current})
                    }
                }
                
                adm.clear();
                adm.append(matches);
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
                StandardListItem
                {
                    id: sli
                    title: ListItemData.name
                    status: ListItemData.surah_id
                }
            }
        ]
        
        onTriggered: {
            var data = dataModel.data(indexPath);
            picked(data.surah_id, 0);
        }
    }
    
    attachedObjects: [
        Timer {
            interval: 150
            repeat: false
            running: true
            
            onTriggered: {
                titleBar.kindProperties.textField.textChanging("");
                titleBar.kindProperties.textField.requestFocus();
            }
        }
    ]
}