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
        AddIndividual,
        AddLocation,
        AddParent,
        AddQuote,
        AddSibling,
        AddStudent,
        AddTafsir,
        AddTafsirPage,
        AddTeacher,
        AddWebsite,
        EditBioLink,
        EditChoice,
        EditIndividual,
        EditLocation,
        EditQuestion,
        EditQuote,
        EditTafsir,
        EditTafsirPage,
        FetchAdjacentAyat,
        FetchAllChoices,
        FetchAllIds,
        FetchAllIndividuals,
        FetchAllLocations,
        FetchAllQuotes,
        FetchAllRecitations,
        FetchAllTafsir,
        FetchAllTafsirForSuite,
        FetchAllWebsites,
        FetchAyatsForTafsir,
        FetchBio,
        FetchBioMetadata,
        FetchChapters,
        FetchChildren,
        FetchChoicesForQuestion,
        FetchIndividualData,
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
        LinkAyatsToTafsir,
        MoveToSuite,
        PendingTransaction,
        PortIndividuals,
        RemoveAnswer,
        RemoveBioLink,
        RemoveChild,
        RemoveChoice,
		RemoveIndividual,
        RemoveLocation,
        RemoveQuestion,
        RemoveQuote,
        RemoveParent,
        RemoveSibling,
        RemoveStudent,
        RemoveTafsir,
        RemoveTafsirPage,
        RemoveTeacher,
        RemoveWebsite,
        ReplaceIndividual,
        ReplaceSuite,
        SearchIndividuals,
        SearchQuote,
        SearchTafsir,
        SettingUpTafsir,
        SetupTafsir,
        TranslateQuote,
        TranslateSuitePage,
        UnlinkAyatsFromTafsir,
        UpdateIdWithIndex,
        UpdateSortOrder,
        UpdateTafsirLink
    };
};

}

#endif /* QUERYID_H_ */
