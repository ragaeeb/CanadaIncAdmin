import bb.cascades 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        deviceUtils.cleanUpAndDestroy(page);
    }
    
    IndividualPickerPage
    {
        id: individualPicker
        
        onContentLoaded: {
            navigationPane.parent.unreadContentCount = size;
        }
        
        onPicked: {
            var page = Qt.launch("ProfilePage.qml");
            page.individualId = individualId;
        }
    }
}