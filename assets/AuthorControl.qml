import bb.cascades 1.3
import com.canadainc.data 1.0

Container
{
    id: itf
    property string field: "author"
    property string label
    property variant pickedId
    property string table: "suites"
    property string where
    horizontalAlignment: HorizontalAlignment.Fill
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    onWhereChanged: {
        if (where.length > 0 && !pickedId) {
            ilmHelper.fetchFrequentIndividuals(itf, table, field, 1, where);
        }
    }
    
    function reset()
    {
        tf.text = label;
        tf.resetImageSource();
    }
    
    onPickedIdChanged: {
        if (pickedId) {
            ilmHelper.fetchIndividualData(itf, pickedId);
        } else {
            reset();
        }
    }
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchIndividualData)
        {
            if (data.length > 0)
            {
                tf.imageSource = "images/dropdown/selected_author.png"
                tf.text = data[0].displayName ? data[0].displayName : data[0].name;
            } else {
                reset();
            }
        } else if (id == QueryId.FetchAllIndividuals && data.length > 0) {
            pickedId = data[0].id;
        }
    }
    
    Button
    {
        id: tf
        text: label
        horizontalAlignment: HorizontalAlignment.Fill
        leftMargin: 0; rightMargin: 0
        
        function onPicked(id, name)
        {
            pickedId = id;
            navigationPane.pop();
        }
        
        onClicked: {
            console.log("UserEvent: ITFClicked");
            definition.source = "IndividualPickerPage.qml";
            
            var p = definition.createObject();
            p.picked.connect(onPicked);
            ilmHelper.fetchFrequentIndividuals(p.pickerList, table, field, 12, where);
            
            navigationPane.push(p);
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
            console.log("UserEvent: CancelITF");
            pickedId = undefined;
        }

        layoutProperties: StackLayoutProperties {
            spaceQuota: 0.05
        }
    }
}