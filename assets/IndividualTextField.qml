import bb.cascades 1.3
import com.canadainc.data 1.0

Button
{
    id: tf
    property string table: "suites"
    property string field: "author"
    property variant pickedId
    horizontalAlignment: HorizontalAlignment.Fill
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchIndividualData && data.length > 0)
        {
            imageSource = "images/dropdown/ic_tabi_tabiee.png"
            text = data[0].displayName ? data[0].displayName : data[0].name;
        }
    }
    
    onPickedIdChanged: {
        if (pickedId) {
            ilmHelper.fetchIndividualData(tf, pickedId);
        }
    }
    
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
        ilmHelper.fetchFrequentIndividuals(p.pickerList, table, field, 12);
        
        navigationPane.push(p);
    }
}