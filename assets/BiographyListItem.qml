import bb.cascades 1.4

StandardListItem
{
    id: bioRoot
    title: ListItemData.target
    imageSource: ListItemData.points == 1 ? "images/list/ic_like.png" : ListItemData.points == -1 ? "images/list/ic_dislike.png" : ListItemData.points == 2 ? "images/tabs/ic_bio.png" : ListItemData.points == 3 ? "images/dropdown/ic_student_knowledge.png" : "images/list/ic_sibling.png"
    
    contextActions: [
        ActionSet
        {
            title: bioRoot.title
            
            ActionItem
            {
                imageSource: "images/menu/ic_bio_link_edit.png"
                title: qsTr("Edit") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: UpdateBioLink");
                    bioRoot.ListItem.view.updateBioLink(bioRoot.ListItem);
                }
            }
            
            ActionItem
            {
                imageSource: "images/menu/ic_birth_city.png"
                title: qsTr("Birth City") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CreateBirthCityQuestion");
                    bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("Where was %1 born?"), qsTr("%1 was born in %2."), qsTr("Was %1 was born in %2?") );
                }
            }
            
            ActionItem
            {
                imageSource: "images/menu/ic_death_age.png"
                title: qsTr("Death Age") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CreateDeathAgeQuestion");
                    bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("How old was %1 (رحمه الله) when he passed away?"), qsTr("%1 (رحمه الله) was %2 when he passed away."), qsTr("Was %1 (رحمه الله) %2 when he passed away?") );
                }
            }
            
            ActionItem
            {
                imageSource: "images/menu/ic_masters_univ.png"
                title: qsTr("Masters University") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CreateMastersUnivQuestion");
                    bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What university did %1 complete his Masters Degree in?"), qsTr("%1 completed his Masters Degree in %2."), qsTr("Did %1 complete his Masters Degree in %2?") );
                }
            }
            
            ActionItem
            {
                imageSource: "images/menu/ic_masters_year.png"
                title: qsTr("Masters Year") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CreateMastersYearQuestion");
                    bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What year did %1 complete his Masters Degree?"), qsTr("%1 completed his Masters Degree in %2 AH."), qsTr("Did %1 complete his Masters Degree in %2 AH?") );
                }
            }
            
            ActionItem
            {
                imageSource: "images/menu/ic_phd_univ.png"
                title: qsTr("PhD University") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CreatePhDUnivQuestion");
                    bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What university did %1 complete his PhD in?"), qsTr("%1 completed his PhD in %2."), qsTr("Did %1 complete his PhD in %2?") );
                }
            }
            
            ActionItem
            {
                imageSource: "images/menu/ic_phd_year.png"
                title: qsTr("PhD Year") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CreatePhDYearQuestion");
                    bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What year did %1 complete his PhD?"), qsTr("%1 completed his PhD in %2 AH."), qsTr("Did %1 complete his PhD in %2 AH?") );
                }
            }
            
            ActionItem
            {
                imageSource: "images/menu/ic_tribe.png"
                title: qsTr("Tribe") + Retranslate.onLanguageChanged
                
                onTriggered: {
                    console.log("UserEvent: CreateTribeQuestion");
                    bioRoot.ListItem.view.produceQuestion( ListItemData, qsTr("What tribe was %1 from?"), qsTr("%1 was from the tribe of %2."), qsTr("Was %1 from the tribe of %2?") );
                }
            }
            
            DeleteActionItem
            {
                imageSource: "images/menu/ic_remove_bio.png"
                
                onTriggered: {
                    console.log("UserEvent: DeleteBioLink");
                    bioRoot.ListItem.view.removeMention(bioRoot.ListItem);
                }
            }
        }
    ]
}