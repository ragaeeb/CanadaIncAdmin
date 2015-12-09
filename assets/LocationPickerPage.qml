import bb.cascades 1.2
import bb.system 1.0
import com.canadainc.data 1.0

Page
{
    id: individualPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    signal picked(variant cityId, string name)
    
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
        
        ActionItem {
            id: remoteSearch
            imageSource: "images/menu/ic_search_location.png"
            title: qsTr("Remote Search") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.OnBar
            
            onTriggered: {
                console.log("UserEvent: SearchLocationTriggered");
                app.geoLookup( searchField.text.trim() );                
            }
        }
    ]
    
    titleBar: TitleBar {
        title: qsTr("Select Location") + Retranslate.onLanguageChanged
        scrollBehavior: TitleBarScrollBehavior.NonSticky
    }
    
    function performSearch()
    {
        var trimmed = searchField.text.trim();
        
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
                searchField.requestFocus();
            }
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            TextField
            {
                id: searchField
                hintText: qsTr("Enter text to search...") + Retranslate.onLanguageChanged
                horizontalAlignment: HorizontalAlignment.Fill
                bottomMargin: 0
                
                input {
                    submitKey: SubmitKey.Search
                    flags: TextInputFlag.AutoCapitalizationOff | TextInputFlag.SpellCheck | TextInputFlag.WordSubstitutionOff | TextInputFlag.AutoPeriodOff | TextInputFlag.AutoCorrectionOff
                    submitKeyFocusBehavior: SubmitKeyFocusBehavior.Lose
                    
                    onSubmitted: {
                        performSearch();
                    }
                }
                
                onCreationCompleted: {
                    input["keyLayout"] = 7;
                }
                
                animations: [
                    TranslateTransition {
                        fromY: -150
                        toY: 0
                        easingCurve: StockCurve.ExponentialOut
                        duration: 200
                        
                        onCreationCompleted: {
                            play();
                        }
                        
                        onStarted: {
                            searchField.requestFocus();
                        }
                        
                        onEnded: {
                            deviceUtils.attachTopBottomKeys(individualPage, listView);
                        }
                    }
                ]
                
                gestureHandlers: [
                    DoubleTapHandler {
                        onDoubleTapped: {
                            console.log("UserEvent: WebsiteBodyDT"); 
                            searchField.text = persist.getClipboardText().trim();
                        }
                    }
                ]
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
}