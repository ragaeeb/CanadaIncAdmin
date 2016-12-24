#ifndef QUERYID_H_
#define QUERYID_H_

#include <qobjectdefs.h>

namespace admin {

class QueryId
{
    Q_GADGET
    Q_ENUMS(Type)

public:
    enum Type {
        AddMention,
        EditAnswer,
        EditCenter,
        EditChoice,
        EditIndividual,
        EditLocation,
        EditMention,
        EditQuestion,
        EditQuote,
        EditSuite,
        EditSuitePage,
        EditTag,
        FetchAdjacentChoices,
        FetchAllCenters,
        FetchAllChoices,
        FetchAllCollections,
        FetchAllIds,
        FetchAllIndividuals,
        FetchAllLocations,
        FetchAllQuestions,
        FetchAllQuotes,
        FetchAllRecitations,
        FetchAllTafsir,
        FetchAllTafsirForSuite,
        FetchAllWebsites,
        FetchAyatsForTafsir,
        FetchBioMetadata,
        FetchCenter,
        FetchChapters,
        FetchChildren,
        FetchChoicesForQuestion,
        FetchExplanationsFor,
        FetchGroupedNarrations,
        FetchGroupsForNarration,
        FetchIndividualData,
        FetchLocationInfo,
        FetchMentions,
        FetchNarration,
        FetchNarrationsInGroup,
        FetchNarrationsForSuitePage,
        FetchNextGroupNumber,
        FetchPageNumbers,
        FetchParents,
        FetchQuestion,
        FetchQuestionsForSuitePage,
        FetchQuote,
        FetchRandomQuote,
        FetchRelations,
        FetchSiblings,
        FetchSimilarAyatContent,
        FetchStudents,
        FetchSuitePageIntersection,
        FetchTafsirContent,
        FetchTafsirHeader,
        FetchTagsForChoices,
        FetchTagsForSuitePage,
        FetchTeachers,
        FindDuplicates,
        GroupNarrations,
        LinkAyatToSuitePage,
        LinkNarrationsToSuitePage,
        MoveToSuite,
        Pending,
        RemoveAnswer,
        RemoveBook,
        RemoveChild,
        RemoveChoice,
		RemoveIndividual,
        RemoveLocation,
        RemoveMention,
        RemoveQuestion,
        RemoveQuote,
        RemoveParent,
        RemoveRelation,
        RemoveSibling,
        RemoveStudent,
        RemoveSuite,
        RemoveSuitePage,
        RemoveTag,
        RemoveTeacher,
        RemoveWebsite,
        ReplaceIndividual,
        ReplaceSuite,
        ReportTypo,
        SearchIndividuals,
        SearchQuote,
        SearchNarrations,
        SearchTafsir,
        SearchTags,
        SettingUpTafsir,
        SetupTafsir,
        TagChoices,
        TagSuites,
        TranslateQuote,
        TranslateSuitePage,
        UnlinkAyatsFromTafsir,
        UnlinkNarrationsFromSuitePage,
        UnlinkNarrationsFromSimilar,
        UpdateGroupNumbers,
        UpdateIdWithIndex,
        UpdateSortOrder,
        UpdateTafsirLink,
        FindLegacy
    };
};

}

#endif /* QUERYID_H_ */
