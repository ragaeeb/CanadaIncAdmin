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
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchNarration && data.length > 0)
        {
            var hadith = data[0];

            body.text = hadith.body;
            tb.title = hadith.name+" "+hadith.hadith_number;
        } else if (id == QueryId.SearchNarrations) {
            adm.clear();
            adm.append(data);
            similar.subtitle = data.length;
            similar.visible = !adm.isEmpty();
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
            
            Label
            {
                id: body
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                multiline: true
            }
        }
        
        Header {
            id: similar
            title: qsTr("Similar") + Retranslate.onLanguageChanged
        }
        
        ListView
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            visible: similar.visible
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    NarrationListItem {}
                }
            ]
        }
    }
}