import QtQuick 1.0
import bb.cascades 1.3
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: individualPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal picked(variant cityId, string name)
    property string prefill
    property alias pickerList: listView
    
    actions: [
        ActionItem {
            id: addLocation
            imageSource: "images/menu/ic_add_location.png"
            title: qsTr("Add Location") + Retranslate.onLanguageChanged
            ActionBar.placement: 'Signature' in ActionBarPlacement ? ActionBarPlacement["Signature"] : ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: NewLocation");
                var latitude = parseFloat( persist.showBlockingPrompt( qsTr("Enter latitude"), qsTr("Please enter the latitude of this location:"), "", qsTr("Enter any non-zero value"), 15, false, qsTr("OK"), qsTr("Cancel"), SystemUiInputMode.NumbersAndPunctuation ).trim() );
                
                if ( latitude != 0 && !isNaN(latitude) )
                {
                    var longitude = parseFloat( persist.showBlockingPrompt( qsTr("Enter longitude"), qsTr("Please enter the longitude of this location:"), "", qsTr("Enter any non-zero value"), 15, false, qsTr("OK"), qsTr("Cancel"), SystemUiInputMode.NumbersAndPunctuation ).trim() );
                    
                    if ( longitude != 0 && !isNaN(longitude) )
                    {
                        var city = persist.showBlockingPrompt( qsTr("Enter city"), qsTr("Please enter the name of this location:"), "", qsTr("Enter any non-empty value"), 20, false, qsTr("OK"), qsTr("Cancel"), SystemUiInputMode.Default ).trim();
                        
                        if (city.length > 0)
                        {
                            var d = ilmHelper.addLocation(city, latitude, longitude);
                            adm.insert(0, d);
                        }
                    }
                }
            }
            
            shortcuts: [
                SystemShortcut {
                    type: SystemShortcuts.CreateNew
                }
            ]
        },
        
        ActionItem
        {
            id: remoteSearch
            imageSource: "images/menu/ic_search_location.png"
            title: qsTr("Remote Search") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SearchLocationTriggered");
                
                var trimmed = tftk.textField.text.trim();
                
                if ( trimmed.match("\\d.+\\s[NS]{1},\\s+\\d.+\\s[EW]{1}") ) {
                    var tokens = trimmed.split(",");
                    app.geoLookup( parseCoordinate(tokens[0]), parseCoordinate(tokens[1]) );
                } else if ( trimmed.match("-{0,1}\\d.+,\\s+-{0,1}\\d.+") ) {
                    var tokens = trimmed.split(",");
                    app.geoLookup( parseFloat( tokens[0].trim() ), parseFloat( tokens[1].trim() ) );
                } else {
                    app.geoLookup(trimmed);
                }                
            }
        }
    ]
    
    titleBar: TitleBar
    {
        kind: TitleBarKind.TextField
        kindProperties: TextFieldTitleBarKindProperties
        {
            id: tftk
            textField.hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
            textField.text: prefill
            textField.input.submitKey: SubmitKey.Search
            textField.input.flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitution | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrection
            textField.input.submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
            textField.input.onSubmitted: {
                performSearch();
            }
            
            onCreationCompleted: {
                textField.input["keyLayout"] = 7;
            }
            
            textField.gestureHandlers: [
                DoubleTapHandler {
                    onDoubleTapped: {
                        console.log("UserEvent: LPPField"); 
                        tftk.textField.text = persist.getClipboardText().trim();
                    }
                }
            ]
        }
    }
    
    function performSearch()
    {
        var trimmed = tftk.textField.text.trim();
        
        if (trimmed.length > 0)
        {
            busy.delegateActive = true;
            noElements.delegateActive = false;
            
            ilmHelper.fetchAllLocations(listView, trimmed);
        } else {
            ilmHelper.fetchAllLocations(listView);
        }
    }
    
    Container
    {
        layout: DockLayout {}
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
        
        EmptyDelegate
        {
            id: noElements
            graphic: "images/placeholders/empty_locations.png"
            labelText: qsTr("No results found for your query. Try another query.") + Retranslate.onLanguageChanged
            
            onImageTapped: {
                tftk.textField.requestFocus();
            }
        }
        
        ListView
        {
            id: listView
            property alias pickerPage: individualPage
            property bool showContextMenu: false
            scrollRole: ScrollRole.Main
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function itemType(data, indexPath)
            {
                if (data.formatted_address) {
                    return "address";
                } else {
                    return "city";
                }
            }
            
            function editLocation(ListItem)
            {
                var element = ListItem.data;
                var currentCity = ListItem.data.city;
                currentCity = persist.showBlockingPrompt( qsTr("Enter city name"), qsTr("Please enter the new name of the city:"), currentCity, qsTr("Enter city name (ie: Damascus)"), 40, true, qsTr("Save"), qsTr("Cancel") ).trim();
                
                if (currentCity.length > 0)
                {
                    element["city"] = currentCity;
                    
                    ilmHelper.editLocation(listView, element.id, currentCity);
                    adm.replace(ListItem.indexPath[0], element);
                }
            }
            
            function deleteCity(ListItem)
            {
                ilmHelper.removeLocation(listView, ListItem.data.id);
                adm.removeAt(ListItem.indexPath[0]);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "city"
                    
                    StandardListItem
                    {
                        id: sli
                        imageSource: "images/list/ic_location.png"
                        status: "(%1,%2)".arg(ListItemData.latitude).arg(ListItemData.longitude)
                        title: ListItemData.city
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sli.title
                                subtitle: sli.description
                                
                                ActionItem
                                {
                                    imageSource: "images/menu/ic_edit_location.png"
                                    title: qsTr("Edit") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: EditLocation");
                                        sli.ListItem.view.editLocation(sli.ListItem);
                                    }
                                }
                                
                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_remove_location.png"
                                    
                                    onTriggered: {
                                        console.log("UserEvent: RemoveCity");
                                        sli.ListItem.view.deleteCity(sli.ListItem);
                                    }
                                }
                            }
                        ]
                    }
                },
                
                ListItemComponent
                {
                    type: "address"
                    
                    StandardListItem
                    {
                        id: address
                        imageSource: "images/list/ic_geo_result.png"
                        status: "(%1,%2)".arg(ListItemData.geometry.location.lat).arg(ListItemData.geometry.location.lng)
                        title: ListItemData.formatted_address
                    }
                }
            ]
            
            function onDataLoaded(id, data)
            {
                if (id == QueryId.FetchAllLocations)
                {
                    adm.clear();
                    adm.append(data);
                    
                    refresh();
                } else if (id == QueryId.RemoveLocation) {
                    persist.showToast( qsTr("Location removed!"), "images/menu/ic_remove_location.png" );
                } else if (id == QueryId.EditLocation) {
                    persist.showToast( qsTr("Location updated!"), "images/menu/ic_edit_location.png" );
                }
            }
            
            onTriggered: {
                var d = dataModel.data(indexPath);
                console.log("UserEvent: CityPicked");
                
                var city = d.formatted_address;
                var locality;
                
                if (city)
                {
                    var parts = d.address_components;
                    var latitude = d.geometry.location.lat;
                    var longitude = d.geometry.location.lng;
                    
                    for (var i = parts.length-1; i >= 0; i--)
                    {
                        var types = parts[i].types;
                        
                        if ( types.indexOf("locality") != -1 ) {
                            locality = parts[i].long_name;
                        }
                    }
                    
                    if (locality) {
                        var useLocality = persist.showBlockingDialog("Loaclity", qsTr("Do you want to use '%1' instead?").arg(locality) );
                        
                        if (useLocality) {
                            city = locality;
                        }
                    }
                    
                    var x = ilmHelper.addLocation(city, latitude, longitude);
                    persist.showToast( qsTr("Location added!"), "images/toast/ic_location_added.png" );
                    picked(x.id, city);
                } else {
                    picked(d.id, d.city);
                }
            }
        }
        
        ProgressControl
        {
            id: busy
            asset: "images/progress/loading_locations.png"
        }
    }
    
    function refresh()
    {
        busy.delegateActive = false;
        noElements.delegateActive = adm.isEmpty();
        listView.visible = !adm.isEmpty();
    }
    
    function onLocationsFound(result)
    {
        if (result.status == "OK")
        {
            adm.clear();
            adm.append(result.results);
            refresh();
        } else {
            persist.showToast( qsTr("Could not fetch geolocation results."), "images/toast/no_geo_found.png", 0 );
        }
    }
    
    function cleanUp() {
        app.locationsFound.disconnect(onLocationsFound);
    }
    
    onCreationCompleted: {
        app.locationsFound.connect(onLocationsFound);
    }
    
    attachedObjects: [
        Timer {
            id: timer
            running: true
            interval: 150
            repeat: false
            
            onTriggered: {
                tftk.textField.requestFocus();
            }
        }
    ]
}