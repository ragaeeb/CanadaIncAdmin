import bb.cascades 1.3
import com.canadainc.data 1.0

Container
{
    id: location
    property string label
    property variant pickedId
    horizontalAlignment: HorizontalAlignment.Fill

    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    onPickedIdChanged: {
        if (pickedId) {
            ilmHelper.fetchLocationInfo(location, pickedId);
        } else {
            reset();
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchLocationInfo)
        {
            if (data.length > 0)
            {
                tf.imageSource = "images/menu/ic_validate_location.png"
                tf.text = data[0].city;
            } else {
                reset();
            }
        }
    }
    
    function onPicked(id, name)
    {
        pickedId = id;
        Qt.navigationPane.pop();
    }

    function reset()
    {
        tf.text = label;
        tf.resetImageSource();
    }

    Button
    {
        id: tf
        text: label
        horizontalAlignment: HorizontalAlignment.Fill
        leftMargin: 0; rightMargin: 0
        
        onClicked: {
            console.log("UserEvent: LFClicked");
            
            var p = Qt.launch("LocationPickerPage.qml");
            p.picked.connect(onPicked);
            ilmHelper.fetchFrequentLocations(p.pickerList);
            
            if (text.length > 0) {
                p.prefill = text;
            }
        }
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 0.95
        }
    }
    
    Button
    {
        imageSource: "images/dropdown/cancel.png"
        leftMargin: 0; rightMargin: 0
        horizontalAlignment: HorizontalAlignment.Right
        
        onClicked: {
            console.log("UserEvent: CancelLF");
            pickedId = undefined;
        }
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 0.05
        }
    }
}