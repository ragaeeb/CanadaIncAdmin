import bb.cascades 1.4

StandardListItem
{
    id: sli
    imageSource: ListItemData.hidden == 1 ? "images/list/ic_hidden.png" : ListItemData.female == 1 ? "images/list/ic_female.png" : global.getImageFor(ListItemData.is_companion)
    title: ListItemData.display_name
    status: ListItemData.death > 0 ? ListItemData.death : undefined
}