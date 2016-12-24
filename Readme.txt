Total # of people who tapped on the "Open Channel"
SELECT SUM(count) FROM events WHERE event='OpenChannelTriggered'

Total # of people who tapped on the "Video Tutorial"
SELECT SUM(count) FROM events WHERE event='VideoTutorialTriggered'

Total # of people who wanted to open github in browser:
SELECT SUM(count) FROM events WHERE event='OpenInBrowser'

Total # of people who clicked the 'Submit Logs':
SELECT SUM(count) FROM events WHERE event='SubmitLogs'

Total # of people who clicked the 'Attach Files':
SELECT SUM(count) FROM events WHERE event='AttachFiles'

Max # of files attached, max # of files attached, avg # of files attached:
SELECT MIN(context) AS min_attach_count,MAX(context) AS max_attach_count,AVG(context) AS avg_attach_count FROM events WHERE event='AttachmentCount'

Total # of people who tried to preview their attachments:
SELECT SUM(count) FROM events WHERE event='AttachPreview'

Total # of Salat10 users:
SELECT COUNT() AS total_users FROM (SELECT DISTINCT user_id FROM events WHERE app='salat10')

Total # of times Salat10 app was launched:
SELECT COUNT() FROM (SELECT event FROM events WHERE event='AppLaunch' AND app='salat10')

Total # of users who want to view the Quran10 tutorial video:
SELECT COUNT() FROM (SELECT user_id FROM events WHERE event='TutorialPromptResult' AND context='video:true' AND app='quran10')

Total # of users who DON'T want to view the Quran10 tutorial video:
SELECT COUNT() FROM (SELECT user_id FROM events WHERE event='TutorialPromptResult' AND context='video:false' AND app='quran10')

Total # of users who confirmed to download the recitations:
SELECT COUNT() FROM (SELECT user_id FROM events WHERE event='DownloadRecitationConfirm' AND context='true')

Total # of users who denied downloading the recitations:
SELECT COUNT() FROM (SELECT user_id FROM events WHERE event='DownloadRecitationConfirm' AND context='false')

Total # of corrupted Mushaf downloads:
SELECT COUNT() FROM (SELECT context FROM events WHERE event='MushafWriteError')

Total # of Mushaf launches:
SELECT SUM(count) FROM events WHERE event='LaunchMushaf'

Total # of Help Page launches for Salat10:
SELECT SUM(count) FROM events WHERE event='HelpPage' AND app='salat10'

Total # of users who were down to donate:
SELECT COUNT() FROM (SELECT user_id FROM events WHERE context='donate:true')

Total # of users who were NOT down to donate:
SELECT COUNT() FROM (SELECT user_id FROM events WHERE context='donate:false')

Total # of users who were down to review:
SELECT COUNT() FROM (SELECT user_id FROM events WHERE context='review:true')

Total # of users who were NOT down to review:
SELECT COUNT() FROM (SELECT user_id FROM events WHERE context='review:false')

Total # of unique users who launched the mushaf:
SELECT COUNT() FROM (SELECT DISTINCT user_id FROM events WHERE event='LaunchMushaf')

Total # of users who have used the surah verse shortcut:
SELECT COUNT() FROM (SELECT DISTINCT user_id FROM events WHERE event='SurahVerseShortcut')

Total # of users who downloaded all the Mushaf pages:
SELECT COUNT() FROM (SELECT DISTINCT user_id FROM events WHERE event='MushafDownloadAll')

Total # of times they tried to play recitations:
SELECT SUM(count) FROM events WHERE event='PlayFrom'

Total # of times multiple verses were copied:
SELECT SUM(count) FROM events WHERE event='MultiCopy'
SELECT SUM(count) FROM events WHERE event='MultiShare'
SELECT SUM(count) FROM events WHERE event='Memorize'

Total # of users who have used the multiple verse copy:
SELECT COUNT() FROM (SELECT DISTINCT user_id FROM events WHERE event='MultiCopy')
SELECT COUNT() FROM (SELECT DISTINCT user_id FROM events WHERE event='MultiShare')
SELECT COUNT() FROM (SELECT DISTINCT user_id FROM events WHERE event='Memorize')

Total # of users who opened biographies:
SELECT COUNT() AS unique_bio_tapped FROM (SELECT DISTINCT user_id FROM events WHERE event='BioTapped' AND context LIKE '%bio')



Total # of times a juz was triggered:
SELECT SUM(count) FROM events WHERE event='JuzTriggered'

Total # of users who have triggered a juz:
SELECT COUNT() FROM (SELECT DISTINCT user_id FROM events WHERE event='JuzTriggered')

Total # of times a supplication was triggered:
SELECT SUM(count) FROM events WHERE event='SupplicationTriggered'

Total # of users who have opened a supplication:
SELECT COUNT() FROM (SELECT DISTINCT user_id FROM events WHERE event='SupplicationTriggered')


Total # of suppression tutorials:
SELECT SUM(count) FROM events WHERE event='SuppressTutorials'

Translation selections for Quran10 in order:
SELECT * FROM (SELECT 'indo' AS translation_lang,COUNT() AS total FROM (SELECT context FROM events WHERE event='Translation' AND context='indo') UNION SELECT 'english' AS translation_lang,COUNT() AS total FROM (SELECT context FROM events WHERE event='Translation' AND context='english') UNION SELECT 'french' AS translation_lang,COUNT() AS total FROM (SELECT context FROM events WHERE event='Translation' AND context='french') UNION SELECT 'arabic' AS translation_lang,COUNT() AS total FROM (SELECT context FROM events WHERE event='Translation' AND context='arabic') UNION SELECT 'french' AS translation_lang,COUNT() AS total FROM (SELECT context FROM events WHERE event='Translation' AND context='french') UNION SELECT 'spanish' AS translation_lang,COUNT() AS total FROM (SELECT context FROM events WHERE event='Translation' AND context='spanish') UNION SELECT 'thai' AS translation_lang,COUNT() AS total FROM (SELECT context FROM events WHERE event='Translation' AND context='thai')) ORDER BY total DESC

Launch time stats for Quran10:
SELECT MIN(context) AS min_window_posted,MAX(context) AS max_window_posted,AVG(context) AS avg_window_posted FROM events WHERE event='com.canadainc.Quran10.gYABgIj2kohPCVRhZD.nLSagI6_1_window_posted'
SELECT MIN(context) AS min_window_posted,MAX(context) AS max_window_posted,AVG(context) AS avg_window_posted FROM events WHERE event='com.canadainc.Quran10.gYABgIj2kohPCVRhZD.nLSagI6_1_process_created'
SELECT MIN(context) AS min_window_posted,MAX(context) AS max_window_posted,AVG(context) AS avg_window_posted FROM events WHERE event='com.canadainc.Quran10.gYABgIj2kohPCVRhZD.nLSagI6_1_fully_visible'

Total # of people who tapped on video tutorial for each app in order from greatest to least
SELECT * FROM (SELECT app,SUM(count) AS count FROM events WHERE event='VideoTutorialTriggered' AND app='ilmtest' UNION SELECT app,SUM(count) FROM events WHERE event='VideoTutorialTriggered' AND app='salat10' UNION SELECT app,SUM(count) FROM events WHERE event='VideoTutorialTriggered' AND app='quran10') ORDER BY count DESC

AlFurqan advertisements:
SELECT * FROM (SELECT event,SUM(count) AS count FROM events WHERE event='AlFurqanTwitter' UNION SELECT event,SUM(count) AS count FROM events WHERE event='AlFurqanFacebook' UNION SELECT event,SUM(count) AS count FROM events WHERE event='AlFurqanEmail' UNION SELECT event,SUM(count) AS count FROM events WHERE event='AlFurqanBBM') ORDER BY count DESC

Total # of people who saw the Al Furqan advertisement:
SELECT SUM(count) FROM events WHERE event='AlFurqanBack'



Salat10 (mute athans/alarms) action item tapped:
SELECT SUM(count) FROM (SELECT count FROM events WHERE event='MuteAthans' AND app='salat10')

Salat10 (athan was previewed in the list)
SELECT SUM(count) FROM (SELECT count FROM events WHERE event='AthanPreview' AND app='salat10')

Salat10 (athan previews in order from highest to lowest):
SELECT * FROM (SELECT context,SUM(count) AS count FROM events WHERE event='AthanPreview' AND app='salat10' AND context='asset:///audio/athan_birmingham.mp3' UNION SELECT context,SUM(count) FROM events WHERE event='AthanPreview' AND app='salat10' AND context='asset:///audio/athan_sahabah.mp3' UNION SELECT context,SUM(count) FROM events WHERE event='AthanPreview' AND app='salat10' AND context='asset:///audio/athan_albaani.mp3' UNION SELECT context,SUM(count) FROM events WHERE event='AthanPreview' AND app='salat10' AND context='asset:///audio/athan_student.mp3') ORDER BY count DESC

Salat10 (tap on Custom to select custom athan)
SELECT SUM(count) FROM (SELECT count FROM events WHERE event='AthanPreviewPick' AND app='salat10')

Salat10 (athan acceptance in order from highest to lowest):
SELECT * FROM (SELECT context,SUM(count) AS count FROM events WHERE event='AcceptAthan' AND app='salat10' AND context='asset:///audio/athan_birmingham.mp3' UNION SELECT context,SUM(count) FROM events WHERE event='AcceptAthan' AND app='salat10' AND context='asset:///audio/athan_sahabah.mp3' UNION SELECT context,SUM(count) FROM events WHERE event='AcceptAthan' AND app='salat10' AND context='asset:///audio/athan_albaani.mp3' UNION SELECT context,SUM(count) FROM events WHERE event='AcceptAthan' AND app='salat10' AND context='asset:///audio/athan_student.mp3' UNION SELECT 'custom',SUM(count) FROM events WHERE event='AcceptAthan' AND app='salat10' AND context LIKE 'file://%') ORDER BY count DESC

Salat10 (athan custom file picked):
SELECT SUM(count) FROM events WHERE event='AthanCustomPicked' AND app='salat10'

Salat10 (athan custom file picker canceled)
SELECT SUM(count) FROM events WHERE event='AthanFileCanceled' AND app='salat10'

CREATE TABLE relationships (id INTEGER PRIMARY KEY, individual integer NOT NULL REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, other_id integer NOT NULL REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, type INTEGER NOT NULL, UNIQUE (individual, other_id, type));

CREATE TABLE narration_typos (id INTEGER PRIMARY KEY, narration_id INTEGER NOT NULL, cursor_start INTEGER, cursor_end INTEGER, reported_time INTEGER, UNIQUE(narration_id,cursor_start,cursor_end) ON CONFLICT IGNORE); 
CREATE TABLE sects (id INTEGER PRIMARY KEY, name TEXT NOT NULL UNIQUE ON CONFLICT IGNORE, birth INTEGER, death INTEGER, founder INTEGER REFERENCES individuals(id) ON DELETE SET NULL ON UPDATE CASCADE, location INTEGER REFERENCES locations(id) ON DELETE SET NULL ON UPDATE CASCADE, parent_id INTEGER REFERENCES sects(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE aliases (id INTEGER PRIMARY KEY, name TEXT, sect_id INTEGER REFERENCES sects(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE beliefs (id INTEGER PRIMARY KEY, title TEXT NOT NULL, negation INTEGER REFERENCES beliefs(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE masjids (id INTEGER PRIMARY KEY, name TEXT, musalla INTEGER, hidden INTEGER, launched INTEGER, website TEXT, email TEXT, description TEXT, location INTEGER REFERENCES locations(id) ON DELETE SET NULL ON UPDATE CASCADE, CHECK(hidden=1 AND name <> '' AND description <> '' AND website <> '' AND email <> ''));
CREATE TABLE affiliations (id INTEGER PRIMARY KEY, person_id INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, friend_id INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE sect_mentions (id INTEGER PRIMARY KEY, target INTEGER REFERENCES sects(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE, points INTEGER); 
CREATE TABLE ascriptions (id INTEGER PRIMARY KEY, person_id INTEGER REFERENCES individuals(id) ON DELETE CASCADE ON UPDATE CASCADE, sect_id INTEGER REFERENCES sects(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE questions (id INTEGER PRIMARY KEY, standard_body TEXT NOT NULL, standard_negation_body TEXT, bool_standard_body TEXT, prompt_standard_body TEXT, ordered_body TEXT, count_body TEXT, bool_count_body TEXT, prompt_count_body TEXT, before_body TEXT, after_body TEXT, difficulty INTEGER, source_id INTEGER REFERENCES questions(id) ON DELETE CASCADE ON UPDATE CASCADE, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE choices (id INTEGER PRIMARY KEY, value_text TEXT, source_id INTEGER REFERENCES choices(id) ON DELETE CASCADE ON UPDATE CASCADE);
CREATE TABLE answers (id INTEGER PRIMARY KEY, question_id INTEGER REFERENCES questions(id) ON DELETE CASCADE ON UPDATE CASCADE, choice_id INTEGER REFERENCES choices(id), sort_order INTEGER, correct INTEGER, UNIQUE(question_id,choice_id) ON CONFLICT IGNORE);
CREATE TABLE narration_explanations (id INTEGER PRIMARY KEY, narration_id INTEGER NOT NULL, suite_page_id INTEGER NOT NULL REFERENCES suite_pages(id) ON DELETE CASCADE, link_type INTEGER, UNIQUE(narration_id, suite_page_id) ON CONFLICT IGNORE);
CREATE TABLE grouped_narrations (id INTEGER PRIMARY KEY, narration_id INTEGER NOT NULL, group_number INTEGER NOT NULL, link_type INTEGER, UNIQUE(narration_id, group_number) ON CONFLICT IGNORE);
CREATE TABLE grouped_choices (id INTEGER PRIMARY KEY, choice_id INTEGER REFERENCES choices(id) ON DELETE CASCADE ON UPDATE CASCADE, tag TEXT NOT NULL, CHECK(tag <> ''), UNIQUE(choice_id,tag) ON CONFLICT IGNORE);
CREATE TABLE grouped_suite_pages (id INTEGER PRIMARY KEY, suite_page_id INTEGER REFERENCES suite_pages(id) ON DELETE CASCADE ON UPDATE CASCADE, tag TEXT NOT NULL, CHECK(tag <> ''), UNIQUE(suite_page_id,tag) ON CONFLICT IGNORE);
CREATE TABLE tags (id INTEGER PRIMARY KEY, tag TEXT NOT NULL UNIQUE, CHECK(tag <> '');
CREATE TABLE hadith_tags (id INTEGER PRIMARY KEY, narration_id INTEGER, tag_id INTEGER NOT NULL REFERENCES tags(id) ON DELETE CASCADE ON UPDATE CASCADE, UNIQUE(narration_id,tag_id) ON CONFLICT IGNORE);