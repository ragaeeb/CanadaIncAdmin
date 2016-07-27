import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: root
    function cleanUp() {}
    signal picked(variant selectedIds)
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchAllCollections)
        {
            adm.clear();
            adm.append(data);
        }
    }
    
    titleBar: TitleBar
    {
        id: tb
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            textField.hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
            textField.input.submitKey: SubmitKey.Submit
            textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.onTextChanging: {
                var trimmed = tftk.textField.text.trim();
                sunnah.fetchAllCollections(root, trimmed);
            }
            
            textField.input.onSubmitted: {
                if ( adm.size() == 1 ) {
                    listView.triggered([0]);
                }
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        animations: [
            FadeTransition {
                fromOpacity: 0
                toOpacity: 1
                duration: 100
                delay: 15
                
                onCreationCompleted: {
                    play();
                }
                
                onEnded: {
                    tftk.textField.textChanging("");
                    tftk.textField.requestFocus();
                }
            }
        ]
        
        ListView
        {
            id: listView
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    StandardListItem
                    {
                        imageSource: "images/list/ic_book.png"
                        title: ListItemData.name
                        
                        contextActions: [
                            ActionSet {}
                        ]
                    }
                }
            ]
            
            multiSelectHandler.actions: [
                ActionItem
                {
                    imageSource: "images/menu/ic_accept.png"
                    title: qsTr("Accept") + Retranslate.onLanguageChanged
                    
                    onTriggered: {
                        var all = listView.selectionList();
                        var result = [];
                        
                        for (var i = all.length-1; i >= 0; i--) {
                            result.push( adm.data(all[i]) );
                        }
                        
                        picked(result);
                    }
                }
            ]
            
            onTriggered: {
                console.log("UserEvent: CollectionTapped");
                picked( [ dataModel.data(indexPath) ] );
            }
        }
    }
}