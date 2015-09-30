#ifndef QuranHelper_H_
#define QuranHelper_H_

#define AYAT_NUMERIC_PATTERN "^\\d{1,3}:\\d{1,3}$"
#define SIMILAR_DB "similar"
#define TAFSIR_ARABIC_DB "tafsir_arabic"
#define ENGLISH_TRANSLATION "english"

#include "QueryId.h"

#include <QFutureWatcher>
#include <QVariant>

namespace canadainc {
    class DatabaseHelper;
}

namespace quran {

using namespace admin;
using namespace canadainc;

class QuranHelper : public QObject
{
	Q_OBJECT

	DatabaseHelper* m_sql;
	QStringList m_chapters;
	QFutureWatcher<QStringList> m_chaptersWatcher;
	QString m_name;

private slots:
    void onCaptureCompleted();
    void onChaptersFetched();

signals:
    void ayatsCaptured(QVariantList const& result);

public:
	QuranHelper(DatabaseHelper* sql);
	virtual ~QuranHelper();

	void lazyInit();

    Q_INVOKABLE void captureAyats(QString const& body);
    Q_INVOKABLE void fetchAyatsForTafsir(QObject* caller, qint64 suitePageId);
    Q_INVOKABLE void linkAyatToTafsir(QObject* caller, qint64 suitePageId, int chapter, int fromVerse, int toVerse, QueryId::Type linkId=QueryId::LinkAyatsToTafsir);
    Q_INVOKABLE void linkAyatsToTafsir(QObject* caller, qint64 suitePageId, QVariantList const& chapterVerseData);
    Q_INVOKABLE void unlinkAyatsForTafsir(QObject* caller, QVariantList const& ids, qint64 suitePageId);
    Q_INVOKABLE void updateTafsirLink(QObject* caller, qint64 explanationId, int surahId, int fromVerse, int toVerse);

    void setDatabaseName(QString const& name);
    Q_INVOKABLE QStringList chapters() const;
    void analyzeKingFahadFrench(QString text);
};

} /* namespace quran */
#endif /* QuranHelper_H_ */
