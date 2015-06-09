CREATE TABLE sects (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE ON CONFLICT IGNORE, birth INTEGER, death INTEGER, founder INTEGER REFERENCES individuals(id) ON DELETE SET NULL ON UPDATE CASCADE, location INTEGER REFERENCES locations(id) ON DELETE SET NULL ON UPDATE CASCADE);
CREATE TABLE individuals (id INTEGER PRIMARY KEY, prefix TEXT, name TEXT, kunya TEXT, hidden INTEGER, birth INTEGER, death INTEGER, female INTEGER, displayName TEXT, location INTEGER REFERENCES locations(id) ON DELETE SET NULL ON UPDATE CASCADE, is_companion INTEGER, CHECK(is_companion=1 AND female=1 AND hidden=1 AND name <> '' AND prefix <> '' AND kunya <> '' AND displayName <> ''));







void AdminHelper::analyzeKingFahadFrench(QString text)
{
    LOGGER( text.size() );
/*
    QMap<int,Surah> surahIdToMetadata;
    QStringList tafsirs; // all the tafsir texts for the ayats
    QMap<int,int> tafsirIdToAyat; // maps the tafsir ID to the ayat #. for example 2,3 means (2) maps to ayat #3, which means ayats[2]
    QVariantMap surahIdToData; // 1 maps to a QVariantMap, which has keys: "translation", "transliteration", "tafsir", "verses" is a QVariantList of QVariantMaps with keys: "content"

    QRegExp chapterRegex = QRegExp("^(SOURATE)\\s+\\d+");
    QRegExp ayatRegex = QRegExp("^\\d+\\.");
    QRegExp chapterReferenceRegex = QRegExp("\\(\\d+\\)$");
    QRegExp tafsirRegex = QRegExp("^\\(\\d+\\)");

    text = text.trimmed();
    QStringList lines = text.split("\n");
    lines.removeAll("\n");
    lines.removeAll("");
    int n = lines.size();

    int currentChapter = 0;
    QStringList currentAyats; // all the translated ayats, index 0 has first ayat, index 1 has second ayat, and so on...

    for (int i = 0; i < n; i++)
    {
        QString line = lines[i].trimmed();

        if ( !line.isEmpty() )
        {
            if ( chapterRegex.indexIn(line) == 0 )
            {
                QVariantMap s;
                currentChapter = line.split("\\s+").last().toInt();
                line = lines[++i].toLower();
                int spaceIndex = line.indexOf(" ");
                s["transliteration"] = TextUtils::toTitleCase( line.left(spaceIndex) );

                QString translation = line.mid(spaceIndex+1);

                if ( chapterReferenceRegex.exactMatch(translation) )
                {
                    int lastLeft = translation.lastIndexOf("(");
                    QString referenceStr = translation.mid(lastLeft+1);
                    referenceStr.chop(1); // remove the last bracket
                    tafsirIdToAyat.insert( referenceStr.toInt(), 0 ); // references the chapter itself and not any ayat

                    translation = translation.remove( lastLeft, translation.length()-lastLeft );
                }

                TextUtils::removeBrackets(translation);
                s["translation"] = translation;

                i += 2; // next line is # of verses, and next line is revelation order
                line = lines[++i];

                if ( ayatRegex.indexIn(line) != 0 ) {
                    s["tafsir"] = line;
                }

                surahIdToMetadata.insert(currentChapter, s);
            }

            if ( ayatRegex.indexIn(line) == 0 )
            {
                line.remove( 0, line.indexOf(" ")+1 );

                int verseId = currentAyats.size()+1;
                QRegExp ayatTafsirReferenceRegex = QRegExp("\\(\\d+\\)");
                int pos = 0;
                while ( (pos = ayatTafsirReferenceRegex.indexIn(line, pos) ) != -1)
                {
                    QString current = ayatTafsirReferenceRegex.capturedTexts().first();
                    int tafsirId = TextUtils::removeBrackets(current).toInt();
                    tafsirIdToAyat.insert(tafsirId, verseId);

                    pos += ayatTafsirReferenceRegex.matchedLength();
                }

                line.remove(ayatTafsirReferenceRegex);
                line.remove("  ");
                currentAyats << line.trimmed();
            }

            if ( tafsirRegex.indexIn(line) == 0 )
            {
                line.remove( 0, line.indexOf(" ")+1 );
                tafsirs << line;
            }
        }
    }

    LOGGER( "**" << tafsirIdToAyat );
    LOGGER("** ayats" << currentAyats);
    LOGGER("** tafsirs" << tafsirs); */
}