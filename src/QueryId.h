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
        AddBioLink,
        AddChild,
        AddParent,
        AddSibling,
        AddStudent,
        AddTeacher,
        EditAnswer,
        EditBioLink,
        EditCenter,
        EditChoice,
        EditIndividual,
        EditLocation,
        EditQuestion,
        EditQuote,
        EditSuite,
        EditSuitePage,
        FetchAdjacentAyat,
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
        FetchBio,
        FetchBioMetadata,
        FetchBooksForAuthor,
        FetchCenter,
        FetchChapters,
        FetchChildren,
        FetchChoicesForQuestion,
        FetchGroupedNarrations,
        FetchIndividualData,
        FetchNarrationsForSuitePage,
        FetchNextGroupNumber,
        FetchPageNumbers,
        FetchParents,
        FetchQuestion,
        FetchQuestionsForSuitePage,
        FetchQuote,
        FetchRandomQuote,
        FetchSiblings,
        FetchSimilarAyatContent,
        FetchStudents,
        FetchSuitePageIntersection,
        FetchTafsirContent,
        FetchTafsirHeader,
        FetchTeachers,
        FindDuplicates,
        GroupNarrations,
        LinkAyatToSuitePage,
        LinkNarrationsToSuitePage,
        MoveToSuite,
        Pending,
        PortIndividuals,
        RemoveAnswer,
        RemoveBioLink,
        RemoveBook,
        RemoveChild,
        RemoveChoice,
		RemoveIndividual,
        RemoveLocation,
        RemoveQuestion,
        RemoveQuote,
        RemoveParent,
        RemoveSibling,
        RemoveStudent,
        RemoveSuite,
        RemoveSuitePage,
        RemoveTeacher,
        RemoveWebsite,
        ReplaceIndividual,
        ReplaceSuite,
        SearchIndividuals,
        SearchQuote,
        SearchNarrations,
        SearchTafsir,
        SettingUpTafsir,
        SetupTafsir,
        TagSuites,
        TranslateQuote,
        TranslateSuitePage,
        UnlinkAyatsFromTafsir,
        UnlinkNarrationsFromSuitePage,
        UnlinkNarrationsFromSimilar,
        UpdateGroupNumbers,
        UpdateIdWithIndex,
        UpdateSortOrder,
        UpdateTafsirLink
    };
};

}

#endif /* QUERYID_H_ */
