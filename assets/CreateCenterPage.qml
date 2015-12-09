import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: createPage
    property variant centerId
    signal createCenter(variant id, string name, string website, variant location)
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    onCenterIdChanged: {
        if (centerId) {
            salat.fetchCenter(createPage, centerId);
        }
    }
    
    function onDataLoaded(id, results)
    {
        if (id == QueryId.FetchCenter && results.length > 0)
        {
            var data = results[0];
            
            nameField.text = data.name;
            website.text = data.website;
            location.locationId = data.location;
            location.text = data.location_name;
        }
    }
    
    titleBar: TitleBar
    {
        title: centerId > 0 ? qsTr("Edit Center") + Retranslate.onLanguageChanged : qsTr("New Center") + Retranslate.onLanguageChanged
        
        acceptAction: ActionItem
        {
            title: qsTr("Save") + Retranslate.onLanguageChanged
            imageSource: "images/dropdown/save_quote.png"
            enabled: true
            
            onTriggered: {
                console.log("UserEvent: CreateCenter");
                nameField.validator.validate();
                website.validator.validate();
                
                if ( nameField.validator.valid && website.validator.valid && location.locationId ) {
                    createCenter( centerId, nameField.text.trim(), website.text.trim(), location.locationId );
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
            
            TextField
            {
                id: nameField
                hintText: qsTr("Name") + Retranslate.onLanguageChanged
                
                validator: Validator
                {
                    errorMessage: qsTr("Center name cannot be empty...") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: {
                        valid = nameField.text.trim().length > 0;
                    }
                }
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: CenterNameDT"); 
                            nameField.text = persist.getClipboardText().trim();
                        }
                    }
                ]
            }
            
            TextField
            {
                id: website
                hintText: qsTr("Website") + Retranslate.onLanguageChanged
                
                validator: Validator
                {
                    errorMessage: qsTr("Invalid website...") + Retranslate.onLanguageChanged
                    mode: ValidationMode.FocusLost
                    
                    onValidate: {
                        valid = textUtils.isUrl( website.text.trim() );
                    }
                }
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: WebsiteBodyDT"); 
                            website.text = persist.getClipboardText().trim();
                        }
                    }
                ]
            }
            
            Button
            {
                id: location
                property variant locationId
                horizontalAlignment: HorizontalAlignment.Center
                
                function onPicked(id, name)
                {
                    locationId = id;
                    text = name;
                    navigationPane.pop();
                }
                
                onClicked: {
                    definition.source = "LocationPickerPage.qml";
                    var p = definition.createObject();
                    p.picked.connect(onPicked);
                    
                    navigationPane.push(p);
                }
            }
        }
    }
}