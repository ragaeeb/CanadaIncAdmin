import QtQuick 1.0
import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: narrationPage
    function cleanUp() {}
    property variant narrationId
    
    onNarrationIdChanged: {
        if (narrationId) {
            sunnah.fetchNarration(narrationPage, narrationId);
            sunnah.fetchSimilarNarrations(narrationPage, [narrationId]);
        }
    }
    
    actions: [
        ActionItem
        {
            imageSource: "images/menu/ic_preview_hadith.png"
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.Signature
            
            onTriggered: {
                console.log("UserEvent: CopyHadith");
                persist.copyToClipboard( body.original+"\n\n"+tb.title);
            }
        }
    ]
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchNarration && data.length > 0)
        {
            var hadith = data[0];

            body.text = body.original = hadith.body;
            tb.title = hadith.name+" "+hadith.hadith_number;
        } else if (id == QueryId.SearchNarrations) {
            adm.clear();
            adm.append(data);
            listView.visible = !adm.isEmpty();
            
            if ( !adm.isEmpty() && body.text.length < 600 ) {
                decorator.decorateSimilar(data, adm, body, "body");
            }
        }
    }
    
    titleBar: TitleBar {
        id: tb
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            leftPadding: 10; rightPadding: 10; topPadding: 10
            
            ScrollView
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                Label
                {
                    id: body
                    property string decorated
                    property string original
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    multiline: true
                    
                    onDecoratedChanged: {
                        original = text;
                        text = decorated;
                    }
                }
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: listView.visible ? 1 : 0.5
            }
        }
        
        ListView
        {
            id: listView
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent {
                    NarrationListItem {}
                }
            ]
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: listView.visible ? 1 : 0.5
            }
        }
    }
    
    attachedObjects: [
        SearchDecorator {
            id: decorator
        }
    ]
}