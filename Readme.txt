CREATE TABLE sects (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE ON CONFLICT IGNORE, birth INTEGER, death INTEGER, founder INTEGER REFERENCES individuals(id) ON DELETE SET NULL ON UPDATE CASCADE, location INTEGER REFERENCES locations(id) ON DELETE SET NULL ON UPDATE CASCADE, parent_id INTEGER REFERENCES sects(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE aliases (id INTEGER PRIMARY KEY, name TEXT, sect_id INTEGER REFERENCES sects(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE beliefs (id INTEGER PRIMARY KEY, title TEXT NOT NULL, negation INTEGER REFERENCES beliefs(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE masjids (id INTEGER PRIMARY KEY, name TEXT, musalla INTEGER, hidden INTEGER, launched INTEGER, website TEXT, email TEXT, description TEXT, location INTEGER REFERENCES locations(id) ON DELETE SET NULL ON UPDATE CASCADE, CHECK(hidden=1 AND name <> '' AND description <> '' AND website <> '' AND email <> ''));
CREATE TABLE affiliations (id INTEGER PRIMARY KEY, person_id INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, friend_id INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE sect_mentions (id INTEGER PRIMARY KEY, target INTEGER REFERENCES sects(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE, points INTEGER); 
CREATE TABLE ascriptions (id INTEGER PRIMARY KEY, person_id INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, sect_id INTEGER REFERENCES sects(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE questions (id INTEGER PRIMARY KEY, standard_body TEXT NOT NULL, ordered_body TEXT, count_body TEXT, before_body TEXT, after_body TEXT, difficulty INTEGER, source_id INTEGER REFERENCES questions(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE choices (id INTEGER PRIMARY KEY, value TEXT, source_id INTEGER REFERENCES choices(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE answers (id INTEGER PRIMARY KEY, question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE ON UPDATE CASCADE, choice_id INTEGER REFERENCES choices(id), sort_order INTEGER, correct INTEGER);


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