import bb.cascades 1.3

Page
{
    id: settingsPage
    actionBarAutoHideBehavior: ActionBarAutoHideBehavior.HideOnScroll
    
    titleBar: TitleBar {
        title: qsTr("Settings") + Retranslate.onLanguageChanged
    }
    
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
                
                PersistDropDown
                {
                    title: qsTr("Ilm Language") + Retranslate.onLanguageChanged
                    horizontalAlignment: HorizontalAlignment.Fill
                    key: "translation"
                    
                    Option {
                        text: qsTr("Arabic") + Retranslate.onLanguageChanged
                        value: "arabic"
                    }
                    
                    Option {
                        text: qsTr("English") + Retranslate.onLanguageChanged
                        value: "english"
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