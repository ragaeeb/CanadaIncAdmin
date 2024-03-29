# Config.pri file version 2.0. Auto-generated by IDE. Any changes made by user will be lost!
BASEDIR = $$quote($$_PRO_FILE_PWD_)

device {
    CONFIG(debug, debug|release) {
        profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        } else {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }

    }

    CONFIG(release, debug|release) {
        !profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }
    }
}

simulator {
    CONFIG(debug, debug|release) {
        !profile {
            CONFIG += \
                config_pri_assets \
                config_pri_source_group1
        }
    }
}

config_pri_assets {
    OTHER_FILES += \
        $$quote($$BASEDIR/assets/AuthorControl.qml) \
        $$quote($$BASEDIR/assets/AyatListItem.qml) \
        $$quote($$BASEDIR/assets/BiographyListItem.qml) \
        $$quote($$BASEDIR/assets/ChoiceListItem.qml) \
        $$quote($$BASEDIR/assets/ChoicePickerPage.qml) \
        $$quote($$BASEDIR/assets/CollectionPickerPage.qml) \
        $$quote($$BASEDIR/assets/CreateCenterPage.qml) \
        $$quote($$BASEDIR/assets/CreateIndividualPage.qml) \
        $$quote($$BASEDIR/assets/CreateQuestionPage.qml) \
        $$quote($$BASEDIR/assets/CreateQuotePage.qml) \
        $$quote($$BASEDIR/assets/CreateSuitePage.qml) \
        $$quote($$BASEDIR/assets/CreateTafsirPage.qml) \
        $$quote($$BASEDIR/assets/Dashboard.qml) \
        $$quote($$BASEDIR/assets/GlobalProperties.qml) \
        $$quote($$BASEDIR/assets/IndividualListItem.qml) \
        $$quote($$BASEDIR/assets/IndividualPickerPage.qml) \
        $$quote($$BASEDIR/assets/IndividualsPane.qml) \
        $$quote($$BASEDIR/assets/LinkActionItem.qml) \
        $$quote($$BASEDIR/assets/LinkChoicesAction.qml) \
        $$quote($$BASEDIR/assets/LocationField.qml) \
        $$quote($$BASEDIR/assets/LocationPickerPage.qml) \
        $$quote($$BASEDIR/assets/MasjidsPane.qml) \
        $$quote($$BASEDIR/assets/NarrationGroupPicker.qml) \
        $$quote($$BASEDIR/assets/NarrationListItem.qml) \
        $$quote($$BASEDIR/assets/NarrationPickerPage.qml) \
        $$quote($$BASEDIR/assets/NarrationProfilePage.qml) \
        $$quote($$BASEDIR/assets/ProfileListView.qml) \
        $$quote($$BASEDIR/assets/ProfilePage.qml) \
        $$quote($$BASEDIR/assets/QuestionListItem.qml) \
        $$quote($$BASEDIR/assets/QuestionPickerPage.qml) \
        $$quote($$BASEDIR/assets/QuestionsPane.qml) \
        $$quote($$BASEDIR/assets/QuotesPane.qml) \
        $$quote($$BASEDIR/assets/QuranSurahPicker.qml) \
        $$quote($$BASEDIR/assets/RelationItem.qml) \
        $$quote($$BASEDIR/assets/SettingsPage.qml) \
        $$quote($$BASEDIR/assets/SuitePageLinkView.qml) \
        $$quote($$BASEDIR/assets/SuitePageLinks.qml) \
        $$quote($$BASEDIR/assets/TafsirContentsPage.qml) \
        $$quote($$BASEDIR/assets/TafsirPane.qml) \
        $$quote($$BASEDIR/assets/TafsirPickerPage.qml) \
        $$quote($$BASEDIR/assets/TagPickerPage.qml) \
        $$quote($$BASEDIR/assets/ToggleTextArea.qml) \
        $$quote($$BASEDIR/assets/TypoTrackerDialog.qml) \
        $$quote($$BASEDIR/assets/images/common/bugs/ic_bugs_submit.png) \
        $$quote($$BASEDIR/assets/images/common/ic_bottom.png) \
        $$quote($$BASEDIR/assets/images/common/ic_copy.png) \
        $$quote($$BASEDIR/assets/images/common/ic_offline.png) \
        $$quote($$BASEDIR/assets/images/common/ic_top.png) \
        $$quote($$BASEDIR/assets/images/dropdown/cancel.png) \
        $$quote($$BASEDIR/assets/images/dropdown/flags/ic_arabic.png) \
        $$quote($$BASEDIR/assets/images/dropdown/flags/ic_english.png) \
        $$quote($$BASEDIR/assets/images/dropdown/flags/ic_french.png) \
        $$quote($$BASEDIR/assets/images/dropdown/flags/ic_indo.png) \
        $$quote($$BASEDIR/assets/images/dropdown/flags/ic_spanish.png) \
        $$quote($$BASEDIR/assets/images/dropdown/flags/ic_thai.png) \
        $$quote($$BASEDIR/assets/images/dropdown/flags/ic_urdu.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_accept_new_suite.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_any_narrations.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_companion.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_individual_none.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_save_individual.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_save_question.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_scholar.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_search_all_collections.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_search_specific.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_short_narrations.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_student_knowledge.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_tabi_tabiee.png) \
        $$quote($$BASEDIR/assets/images/dropdown/ic_tabiee.png) \
        $$quote($$BASEDIR/assets/images/dropdown/invalid_name.png) \
        $$quote($$BASEDIR/assets/images/dropdown/question_updated.png) \
        $$quote($$BASEDIR/assets/images/dropdown/save_bio.png) \
        $$quote($$BASEDIR/assets/images/dropdown/save_center.png) \
        $$quote($$BASEDIR/assets/images/dropdown/save_quote.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_author.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_body.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_description.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_quote_body.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_quote_reference.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_quotes_author.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_reference.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_title.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_translator.png) \
        $$quote($$BASEDIR/assets/images/dropdown/search_uri.png) \
        $$quote($$BASEDIR/assets/images/dropdown/selected_author.png) \
        $$quote($$BASEDIR/assets/images/dropdown/starts_with.png) \
        $$quote($$BASEDIR/assets/images/dropdown/suite_changes_accept.png) \
        $$quote($$BASEDIR/assets/images/dropdown/suite_changes_cancel.png) \
        $$quote($$BASEDIR/assets/images/ic_clear.png) \
        $$quote($$BASEDIR/assets/images/ic_percent.png) \
        $$quote($$BASEDIR/assets/images/list/ic_answer_correct.png) \
        $$quote($$BASEDIR/assets/images/list/ic_answer_incorrect.png) \
        $$quote($$BASEDIR/assets/images/list/ic_bio.png) \
        $$quote($$BASEDIR/assets/images/list/ic_book.png) \
        $$quote($$BASEDIR/assets/images/list/ic_child.png) \
        $$quote($$BASEDIR/assets/images/list/ic_child_female.png) \
        $$quote($$BASEDIR/assets/images/list/ic_choice.png) \
        $$quote($$BASEDIR/assets/images/list/ic_companion.png) \
        $$quote($$BASEDIR/assets/images/list/ic_dislike.png) \
        $$quote($$BASEDIR/assets/images/list/ic_email.png) \
        $$quote($$BASEDIR/assets/images/list/ic_female.png) \
        $$quote($$BASEDIR/assets/images/list/ic_folder.png) \
        $$quote($$BASEDIR/assets/images/list/ic_geo_result.png) \
        $$quote($$BASEDIR/assets/images/list/ic_geo_search.png) \
        $$quote($$BASEDIR/assets/images/list/ic_hidden.png) \
        $$quote($$BASEDIR/assets/images/list/ic_individual.png) \
        $$quote($$BASEDIR/assets/images/list/ic_like.png) \
        $$quote($$BASEDIR/assets/images/list/ic_location.png) \
        $$quote($$BASEDIR/assets/images/list/ic_masjid.png) \
        $$quote($$BASEDIR/assets/images/list/ic_narration.png) \
        $$quote($$BASEDIR/assets/images/list/ic_parent.png) \
        $$quote($$BASEDIR/assets/images/list/ic_parent_female.png) \
        $$quote($$BASEDIR/assets/images/list/ic_phone.png) \
        $$quote($$BASEDIR/assets/images/list/ic_question.png) \
        $$quote($$BASEDIR/assets/images/list/ic_question_alias.png) \
        $$quote($$BASEDIR/assets/images/list/ic_quote.png) \
        $$quote($$BASEDIR/assets/images/list/ic_sibling.png) \
        $$quote($$BASEDIR/assets/images/list/ic_sibling_female.png) \
        $$quote($$BASEDIR/assets/images/list/ic_student.png) \
        $$quote($$BASEDIR/assets/images/list/ic_student_female.png) \
        $$quote($$BASEDIR/assets/images/list/ic_tafsir.png) \
        $$quote($$BASEDIR/assets/images/list/ic_tafsir_ayat.png) \
        $$quote($$BASEDIR/assets/images/list/ic_tag.png) \
        $$quote($$BASEDIR/assets/images/list/ic_teacher.png) \
        $$quote($$BASEDIR/assets/images/list/ic_teacher_female.png) \
        $$quote($$BASEDIR/assets/images/list/ic_unique_narration.png) \
        $$quote($$BASEDIR/assets/images/list/ic_whatsapp.png) \
        $$quote($$BASEDIR/assets/images/list/site_facebook.png) \
        $$quote($$BASEDIR/assets/images/list/site_instagram.png) \
        $$quote($$BASEDIR/assets/images/list/site_link.png) \
        $$quote($$BASEDIR/assets/images/list/site_linkedin.png) \
        $$quote($$BASEDIR/assets/images/list/site_soundcloud.png) \
        $$quote($$BASEDIR/assets/images/list/site_tumblr.png) \
        $$quote($$BASEDIR/assets/images/list/site_twitter.png) \
        $$quote($$BASEDIR/assets/images/list/site_wordpress.png) \
        $$quote($$BASEDIR/assets/images/list/site_youtube.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_accept.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_accept_choices.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_accept_narrations.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_accept_tag.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_bio.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_book.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_center.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_child.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_choice.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_email.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_location.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_narration.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_parent.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_phone.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_question.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_quote.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_rijaal.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_search.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_sibling.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_site.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_student.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_suite.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_suite_page.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_tag.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_add_teacher.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_adjacent_choices.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_bio_link_edit.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_birth_city.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_capture_ayats.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_death_age.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_delete_individual.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_delete_quote.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_delete_suite_page.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_duplicate_question.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_bio.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_center.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_choice.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_link.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_location.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_quote.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_rijaal.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_suite.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_edit_suite_page.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_find_duplicate_quotes.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_flip_answer.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_help.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_link.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_link_ayat_to_tafsir.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_link_choices.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_masters_univ.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_masters_year.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_merge.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_merge_into.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_more_items.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_move.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_new_group.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_phd_univ.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_phd_year.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_port.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_preview.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_preview_hadith.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_relink.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_answer.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_bio.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_book.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_child.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_choice.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_companions.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_email.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_location.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_parent.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_phone.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_question.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_sibling.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_site.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_student.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_suite.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_tag.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_remove_teacher.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_reorder.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_reorder_suites.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_replace_individual.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_replicate.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_reset_fields.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_reset_search.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_search.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_search_action.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_search_append.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_search_choices.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_search_individual.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_search_location.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_search_rijaal.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_select_all_narrations.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_select_choices.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_select_individuals.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_select_more.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_set_companions.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_set_marker.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_settings.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_share_db.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_source_choice.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_source_question.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_switch_to_english.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_translate.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_translate_quote.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_tribe.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_unlink.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_unlink_author.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_unlink_narration.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_unlink_tafsir_ayat.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_update_link.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_upload_local.png) \
        $$quote($$BASEDIR/assets/images/menu/ic_validate_location.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_bios.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_centers.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_choices.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_individuals.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_locations.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_narrations.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_quotes.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_suite_ayats.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_suite_pages.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_suites.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_tafsir.png) \
        $$quote($$BASEDIR/assets/images/placeholders/empty_tags.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_bios.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_centers.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_choices.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_individuals.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_locations.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_narrations.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_quotes.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_similar.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_suite_ayats.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_suite_pages.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_suites.png) \
        $$quote($$BASEDIR/assets/images/progress/loading_surah.png) \
        $$quote($$BASEDIR/assets/images/progress/uploading_local.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_bio.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_centers.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_dash.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_narrations.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_questions.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_quotes.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_rijaal.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_tafsir.png) \
        $$quote($$BASEDIR/assets/images/tabs/ic_utils.png) \
        $$quote($$BASEDIR/assets/images/toast/edited_tags.png) \
        $$quote($$BASEDIR/assets/images/toast/ic_add_tag.png) \
        $$quote($$BASEDIR/assets/images/toast/ic_duplicate_replace.png) \
        $$quote($$BASEDIR/assets/images/toast/ic_location_added.png) \
        $$quote($$BASEDIR/assets/images/toast/ic_no_ayat_found.png) \
        $$quote($$BASEDIR/assets/images/toast/ic_no_shared_folder.png) \
        $$quote($$BASEDIR/assets/images/toast/ic_question_edited.png) \
        $$quote($$BASEDIR/assets/images/toast/incomplete_field.png) \
        $$quote($$BASEDIR/assets/images/toast/invalid_entry.png) \
        $$quote($$BASEDIR/assets/images/toast/no_geo_found.png) \
        $$quote($$BASEDIR/assets/images/toast/permission_toast_bg.amd) \
        $$quote($$BASEDIR/assets/images/toast/permission_toast_bg.png) \
        $$quote($$BASEDIR/assets/images/toast/question_entry_warning.png) \
        $$quote($$BASEDIR/assets/images/toast/same_people.png) \
        $$quote($$BASEDIR/assets/images/toast/same_suites.png) \
        $$quote($$BASEDIR/assets/images/toast/similar_found.png) \
        $$quote($$BASEDIR/assets/images/toast/success_upload_local.png) \
        $$quote($$BASEDIR/assets/images/toast/toast_bg.amd) \
        $$quote($$BASEDIR/assets/images/toast/toast_bg.png) \
        $$quote($$BASEDIR/assets/images/toast/transfer_error.png) \
        $$quote($$BASEDIR/assets/main.qml) \
        $$quote($$BASEDIR/assets/xml/quran-data.xml)
}

config_pri_source_group1 {
    SOURCES += \
        $$quote($$BASEDIR/src/CommonConstants.cpp) \
        $$quote($$BASEDIR/src/IlmHelper.cpp) \
        $$quote($$BASEDIR/src/IlmTestHelper.cpp) \
        $$quote($$BASEDIR/src/InvokeHelper.cpp) \
        $$quote($$BASEDIR/src/Offloader.cpp) \
        $$quote($$BASEDIR/src/QuranHelper.cpp) \
        $$quote($$BASEDIR/src/SalatHelper.cpp) \
        $$quote($$BASEDIR/src/SunnahHelper.cpp) \
        $$quote($$BASEDIR/src/TafsirHelper.cpp) \
        $$quote($$BASEDIR/src/ThreadUtils.cpp) \
        $$quote($$BASEDIR/src/TokenHelper.cpp) \
        $$quote($$BASEDIR/src/applicationui.cpp) \
        $$quote($$BASEDIR/src/main.cpp)

    HEADERS += \
        $$quote($$BASEDIR/src/CommonConstants.h) \
        $$quote($$BASEDIR/src/IlmHelper.h) \
        $$quote($$BASEDIR/src/IlmTestHelper.h) \
        $$quote($$BASEDIR/src/InvokeHelper.h) \
        $$quote($$BASEDIR/src/Offloader.h) \
        $$quote($$BASEDIR/src/QueryId.h) \
        $$quote($$BASEDIR/src/QuranHelper.h) \
        $$quote($$BASEDIR/src/SalatHelper.h) \
        $$quote($$BASEDIR/src/SunnahHelper.h) \
        $$quote($$BASEDIR/src/TafsirHelper.h) \
        $$quote($$BASEDIR/src/ThreadUtils.h) \
        $$quote($$BASEDIR/src/TokenHelper.h) \
        $$quote($$BASEDIR/src/applicationui.hpp)
}

CONFIG += precompile_header

PRECOMPILED_HEADER = $$quote($$BASEDIR/precompiled.h)

lupdate_inclusion {
    SOURCES += \
        $$quote($$BASEDIR/../src/*.c) \
        $$quote($$BASEDIR/../src/*.c++) \
        $$quote($$BASEDIR/../src/*.cc) \
        $$quote($$BASEDIR/../src/*.cpp) \
        $$quote($$BASEDIR/../src/*.cxx) \
        $$quote($$BASEDIR/../assets/*.qml) \
        $$quote($$BASEDIR/../assets/*.js) \
        $$quote($$BASEDIR/../assets/*.qs) \
        $$quote($$BASEDIR/../assets/images/*.qml) \
        $$quote($$BASEDIR/../assets/images/*.js) \
        $$quote($$BASEDIR/../assets/images/*.qs) \
        $$quote($$BASEDIR/../assets/images/common/*.qml) \
        $$quote($$BASEDIR/../assets/images/common/*.js) \
        $$quote($$BASEDIR/../assets/images/common/*.qs) \
        $$quote($$BASEDIR/../assets/images/common/bugs/*.qml) \
        $$quote($$BASEDIR/../assets/images/common/bugs/*.js) \
        $$quote($$BASEDIR/../assets/images/common/bugs/*.qs) \
        $$quote($$BASEDIR/../assets/images/dropdown/*.qml) \
        $$quote($$BASEDIR/../assets/images/dropdown/*.js) \
        $$quote($$BASEDIR/../assets/images/dropdown/*.qs) \
        $$quote($$BASEDIR/../assets/images/dropdown/flags/*.qml) \
        $$quote($$BASEDIR/../assets/images/dropdown/flags/*.js) \
        $$quote($$BASEDIR/../assets/images/dropdown/flags/*.qs) \
        $$quote($$BASEDIR/../assets/images/list/*.qml) \
        $$quote($$BASEDIR/../assets/images/list/*.js) \
        $$quote($$BASEDIR/../assets/images/list/*.qs) \
        $$quote($$BASEDIR/../assets/images/menu/*.qml) \
        $$quote($$BASEDIR/../assets/images/menu/*.js) \
        $$quote($$BASEDIR/../assets/images/menu/*.qs) \
        $$quote($$BASEDIR/../assets/images/placeholders/*.qml) \
        $$quote($$BASEDIR/../assets/images/placeholders/*.js) \
        $$quote($$BASEDIR/../assets/images/placeholders/*.qs) \
        $$quote($$BASEDIR/../assets/images/progress/*.qml) \
        $$quote($$BASEDIR/../assets/images/progress/*.js) \
        $$quote($$BASEDIR/../assets/images/progress/*.qs) \
        $$quote($$BASEDIR/../assets/images/tabs/*.qml) \
        $$quote($$BASEDIR/../assets/images/tabs/*.js) \
        $$quote($$BASEDIR/../assets/images/tabs/*.qs) \
        $$quote($$BASEDIR/../assets/images/toast/*.qml) \
        $$quote($$BASEDIR/../assets/images/toast/*.js) \
        $$quote($$BASEDIR/../assets/images/toast/*.qs) \
        $$quote($$BASEDIR/../assets/xml/*.qml) \
        $$quote($$BASEDIR/../assets/xml/*.js) \
        $$quote($$BASEDIR/../assets/xml/*.qs)

    HEADERS += \
        $$quote($$BASEDIR/../src/*.h) \
        $$quote($$BASEDIR/../src/*.h++) \
        $$quote($$BASEDIR/../src/*.hh) \
        $$quote($$BASEDIR/../src/*.hpp) \
        $$quote($$BASEDIR/../src/*.hxx)
}

TRANSLATIONS = $$quote($${TARGET}.ts)
