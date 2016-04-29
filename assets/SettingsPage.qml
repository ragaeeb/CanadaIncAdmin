import bb.cascades 1.3

Page
{
    id: settingsPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
    function cleanUp() {}
    
    Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill
        layout: DockLayout {}
        
        ScrollView
        {  
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            scrollRole: ScrollRole.Main
            
            Container
            {
                leftPadding: 10
                topPadding: 10
                rightPadding: 10
                bottomPadding: 10
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                
                PersistCheckBox
                {
                    id: promptSimilar
                    text: qsTr("Prompt To Link Similar?") + Retranslate.onLanguageChanged
                    key: "promptSimilar"
                }
                
                PersistDropDown
                {
                    title: qsTr("Ilm Language") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    key: "translation"
                    
                    Option {
                        imageSource: "images/dropdown/flags/ic_arabic.png"
                        text: qsTr("Arabic") + Retranslate.onLanguageChanged
                        value: "arabic"
                    }
                    
                    Option {
                        imageSource: "images/dropdown/flags/ic_english.png"
                        text: qsTr("English") + Retranslate.onLanguageChanged
                        value: "english"
                    }
                    
                    Option {
                        text: qsTr("French") + Retranslate.onLanguageChanged
                        value: "french"
                        imageSource: "images/dropdown/flags/ic_french.png"
                    }
                    
                    Option {
                        text: qsTr("Indonesian") + Retranslate.onLanguageChanged
                        value: "indo"
                        imageSource: "images/dropdown/flags/ic_indo.png"
                    }
                    
                    Option {
                        text: qsTr("Spanish") + Retranslate.onLanguageChanged
                        value: "spanish"
                        imageSource: "images/dropdown/flags/ic_spanish.png"
                    }
                    
                    Option {
                        id: thai
                        text: qsTr("Thai") + Retranslate.onLanguageChanged
                        value: "thai"
                        imageSource: "images/dropdown/flags/ic_thai.png"
                    }
                    
                    Option {
                        text: qsTr("Urdu") + Retranslate.onLanguageChanged
                        value: "urdu"
                        imageSource: "images/dropdown/flags/ic_urdu.png"
                    }
                    
                    onValueChanged: {
                        if (diff) {
                            app.loadIlmDatabase();
                        }
                    }
                }
            }
        }
    }
}