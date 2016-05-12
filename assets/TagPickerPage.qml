import bb.cascades 1.3
import com.canadainc.data 1.0

Page
{
    id: searchRoot
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    property variant prepopulated
    property string table: "grouped_suite_pages"
    signal picked(variant picked)
    function cleanUp() {}
    
    onCreationCompleted: {
        deviceUtils.attachTopBottomKeys(searchRoot, listView);
        fader.play();
    }
    
    onPrepopulatedChanged: {
        if (prepopulated) {
            adm.append(prepopulated);
        }
    }
    
    titleBar: TitleBar
    {
        id: tb
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            textField.hintText: qsTr("Enter tag to search...") + Retranslate.onLanguageChanged
            textField.input.submitKey: SubmitKey.Submit
            textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheckOff | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            
            textField.onTextChanging: {
                salat.searchTags(listView, tftk.textField.text.trim(), table);
            }
            
            textField.input.onSubmitted: {
                var trimmed = tftk.textField.text.trim().toLowerCase();

                if (trimmed.length > 0) {
                    picked({'tag': trimmed});
                }
            }
        }
    }
    
    Container
    {
        id: searchContainer
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        animations: [
            FadeTransition
            {
                id: fader
                fromOpacity: 0
                toOpacity: 1
                easingCurve: StockCurve.CubicIn
                duration: 150
                
                onEnded: {
                    tftk.textField.requestFocus();
                    
                    if (!prepopulated || prepopulated.length == 0) {
                        salat.searchTags(listView, "", table);
                    }
                }
            }
        ]
        
        Container
        {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
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
                            id: sli
                            imageSource: "images/list/ic_tag.png"
                            title: ListItemData.tag
                        }
                    }
                ]
                
                function onDataLoaded(id, data)
                {
                    if (id == QueryId.SearchTags)
                    {
                        adm.clear();
                        adm.append(data);
                        updateState();
                    }
                }
                
                onTriggered: {
                    console.log("UserEvent: TagTriggeredFromSearch");
                    picked( dataModel.data(indexPath) );
                }
            }
            
            EmptyDelegate
            {
                id: noElements
                graphic: "images/placeholders/empty_tags.png"
                labelText: qsTr("No results matched your query.") + Retranslate.onLanguageChanged
                
                onImageTapped: {
                    console.log("UserEvent: NoMatches");
                    tftk.textField.requestFocus();
                }
            }
        }
    }
    
    function updateState()
    {
        noElements.delegateActive = adm.isEmpty();
        listView.visible = !adm.isEmpty();
    }
}