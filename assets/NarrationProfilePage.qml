import bb.cascades 1.0
import com.canadainc.data 1.0

Page
{
    id: narrationPage
    function cleanUp() {}
    property variant narrationId

    onNarrationIdChanged: {
        if (narrationId) {
            sunnah.fetchNarrations(narrationPage, [narrationId]);
            sunnah.fetchGroupsForNarration(narrationPage, narrationId);
            sunnah.fetchExplanationsFor(narrationPage, narrationId);
        }
    }
    
    actions: [
        ActionItem
        {
            imageSource: "images/common/ic_copy.png"
            title: qsTr("Copy") + Retranslate.onLanguageChanged
            ActionBar.placement: ActionBarPlacement.Signature
            
            onTriggered: {
                console.log("UserEvent: CopyHadith");
                persist.copyToClipboard( adm.value(0).body+"\n\n"+tb.title);
            }
        }
    ]
    
    function onDataLoaded(id, data)
    {
        if (id == QueryId.FetchNarrations && data.length > 0)
        {
            var hadith = data[0];
            tb.title = "%1 %2".arg(hadith.name).arg(hadith.hadith_number);
            adm.append(data);
        } else if (id == QueryId.FetchGroupsForNarration || id == QueryId.FetchExplanationsFor) {
            adm.append(data);
        } else if (id == QueryId.SearchNarrations && data.length > 0) {
            var c = Qt.launch("NarrationPickerPage.qml");
            c.narrationList.onDataLoaded(QueryId.SearchNarrations, data);
        } else if (id == QueryId.UnlinkNarrationsFromSimilar) {
            persist.showToast( qsTr("Unlinked from group"), "images/menu/ic_unlink.png" );
        } else if (id == QueryId.ReportTypo) {
            persist.showToast( qsTr("Mistake recorded."), "images/common/ic_offline.png" );
        }
    }
    
    titleBar: TitleBar
    {
        id: tb
        
        acceptAction: ActionItem
        {
            imageSource: "images/common/ic_offline.png"
            title: narrationId ? narrationId.toString() : ""
            enabled: listView.selectedText.length > 0
            
            onTriggered: {
                console.log("UserEvent: ReportMistake");
                listView.visible = false;
                browserDef.delegateActive = true;
                persist.copyToClipboard(listView.selectedText);
                
                sunnah.reportTypo(narrationPage, narrationId, listView.selectStart, listView.selectEnd);
                listView.selectedText = "";
            }
        }
    }
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        
        ControlDelegate
        {
            id: browserDef
            delegateActive: false
            
            sourceComponent: ComponentDefinition
            {
                Container
                {
                    horizontalAlignment: HorizontalAlignment.Fill
                    verticalAlignment: VerticalAlignment.Fill
                    
                    ScrollView
                    {
                        id: scrollView
                        horizontalAlignment: HorizontalAlignment.Fill
                        verticalAlignment: VerticalAlignment.Fill
                        scrollViewProperties.scrollMode: ScrollMode.Both
                        scrollViewProperties.pinchToZoomEnabled: true
                        scrollViewProperties.initialScalingMethod: ScalingMethod.AspectFill
                        scrollRole: ScrollRole.Main
                        
                        WebView
                        {
                            id: webView
                            settings.zoomToFitEnabled: true
                            settings.activeTextEnabled: true
                            horizontalAlignment: HorizontalAlignment.Fill
                            verticalAlignment: VerticalAlignment.Fill
                            url: "http://sunnah.com/urn/%1".arg( narrationId.toString() )
                            
                            onLoadProgressChanged: {
                                progressIndicator.value = loadProgress;
                            }
                            
                            onLoadingChanged: {
                                if (loadRequest.status == WebLoadStatus.Started) {
                                    progressIndicator.visible = true;
                                    progressIndicator.state = ProgressIndicatorState.Progress;
                                } else if (loadRequest.status == WebLoadStatus.Succeeded) {
                                    progressIndicator.visible = false;
                                    progressIndicator.state = ProgressIndicatorState.Complete;
                                } else if (loadRequest.status == WebLoadStatus.Failed) {
                                    html = "<html><head><title>Load Fail</title><style>* { margin: 0px; padding 0px; }body { font-size: 48px; font-family: monospace; border: 1px solid #444; padding: 4px; }</style> </head> <body>Loading failed! Please check your internet connection.</body></html>"
                                    progressIndicator.visible = false;
                                    progressIndicator.state = ProgressIndicatorState.Error;
                                }
                            }
                        }
                    }
                    
                    ProgressIndicator
                    {
                        id: progressIndicator
                        horizontalAlignment: HorizontalAlignment.Center
                        verticalAlignment: VerticalAlignment.Center
                        value: 0
                        fromValue: 0
                        toValue: 100
                        opacity: value/100
                        state: ProgressIndicatorState.Pause
                        topMargin: 0; bottomMargin: 0; leftMargin: 0; rightMargin: 0;
                    }
                }
            }
        }
        
        ListView
        {
            id: listView
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            property int selectStart
            property int selectEnd
            property string selectedText
            
            dataModel: ArrayDataModel {
                id: adm
            }
            
            function itemType(data, indexPath)
            {
                if (data.hadith_number) {
                    return "narration";
                } else if (data.title) {
                    return "suitePage";
                } else {
                    return "group"
                }
            }
            
            function unlinkFromGroup(ListItem, ListItemData)
            {
                sunnah.unlinkNarrationFromSimilar(narrationPage, [ListItemData.id]);
                ListItem.view.dataModel.removeAt(ListItem.indexPath[0]);
            }
            
            listItemComponents: [
                ListItemComponent
                {
                    type: "narration"
                    
                    Container
                    {
                        id: rootItem
                        horizontalAlignment: HorizontalAlignment.Fill
                        
                        Header
                        {
                            id: header
                            title: ListItemData.name
                            subtitle: ListItemData.hadith_number
                        }
                        
                        TextArea {
                            id: bodyLabel
                            content.flags: TextContentFlag.ActiveTextOff | TextContentFlag.EmoticonsOff
                            editable: false
                            text: ListItemData.body
                            
                            editor.onSelectedTextChanged: {
                                rootItem.ListItem.view.selectStart = editor.selectionStart;
                                rootItem.ListItem.view.selectEnd = editor.selectionEnd;
                                rootItem.ListItem.view.selectedText = selectedText;
                            }
                        }
                    }
                },
                
                ListItemComponent
                {
                    type: "suitePage"
                    
                    StandardListItem
                    {
                        title: ListItemData.author
                        description: ListItemData.heading && ListItemData.heading.length > 0 ? ListItemData.heading : ListItemData.title
                        imageSource: "images/list/ic_tafsir.png"
                    }
                },
                
                ListItemComponent
                {
                    type: "group"
                    
                    StandardListItem
                    {
                        id: sli
                        imageSource: "images/list/ic_folder.png"
                        title: ListItemData.name ? "%1 (%2)".arg(ListItemData.name).arg(ListItemData.group_number) : qsTr("Group: %1").arg(ListItemData.group_number)
                        
                        contextActions: [
                            ActionSet
                            {
                                title: sli.title

                                DeleteActionItem
                                {
                                    imageSource: "images/menu/ic_unlink.png"
                                    title: qsTr("Unlink") + Retranslate.onLanguageChanged
                                    
                                    onTriggered: {
                                        console.log("UserEvent: UnlinkNarrationFromGroup");
                                        sli.ListItem.view.unlinkFromGroup(sli.ListItem, ListItemData);
                                    }
                                }
                            }
                        ]
                    }
                }
            ]
            
            onTriggered: {
                var element = dataModel.data(indexPath);
                
                if (element.title)
                {
                    var c = Qt.launch("CreateSuitePage.qml");
                    c.suitePageId = element.id;
                } else if (!element.body) {
                    sunnah.fetchNarrationsInGroup(narrationPage, element.group_number);
                }
            }
        }
    }
}