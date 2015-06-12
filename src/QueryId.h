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
        EditIndividual,
        EditLocation,
        EditQuote,
        EditTafsir,
        EditTafsirPage,
        FetchAdjacentAyat,
        FetchAllIndividuals,
        FetchAllLocations,
        FetchParents,
        FetchAllQuotes,
        FetchAllRecitations,
        FetchSiblings,
        FetchAllTafsir,
        FetchAllTafsirForSuite,
        FetchAllWebsites,
        FetchAyatsForTafsir,
        FetchBio,
        FetchBioMetadata,
        FetchChapters,
        FetchChildren,
        FetchIndividualData,
        FetchPageNumbers,
        FetchQuote,
        FetchRandomQuote,
        FetchSimilarAyatContent,
        FetchStudents,
        FetchTafsirContent,
        FetchTafsirHeader,
        FetchTeachers,
        FindDuplicates,
        LinkAyatsToTafsir,
        LinkingAyatsToTafsir,
        RemoveBioLink,
        RemoveChild,
		RemoveIndividual,
        RemoveLocation,
        RemoveQuote,
        RemoveParent,
        RemoveSibling,
        RemoveStudent,
        RemoveTafsir,
        RemoveTafsirPage,
        RemoveTeacher,
        RemoveWebsite,
        ReplacingIndividual,
        ReplaceIndividual,
        ReplacingSuite,
        ReplaceSuite,
        SearchIndividuals,
        SearchQuote,
        SearchTafsir,
        SettingUpTafsir,
        SetupTafsir,
        TranslatingQuote,
        TranslateQuote,
        TranslatingSuitePage,
        TranslateSuitePage,
        UnlinkAyatsFromTafsir,
        UpdateTafsirLink
    };
};

}

#endif /* QUERYID_H_ */
