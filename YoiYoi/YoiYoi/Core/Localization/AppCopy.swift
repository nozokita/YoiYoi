import Foundation

/// UI 文言（`SupportedLanguage` 連動）。String Catalog 本格導入までの集中管理。
enum AppCopy {
    // MARK: - Common

    static func commonBack(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "戻る"; case .en: "Back" }
    }

    static func commonNext(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "次へ"; case .en: "Next" }
    }

    static func commonOK(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "OK"; case .en: "OK" }
    }

    static func commonDelete(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "削除"; case .en: "Delete" }
    }

    // MARK: - Shell

    static func tabHome(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ホーム"; case .en: "Home" }
    }

    static func tabCalendar(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "カレンダー"; case .en: "Calendar" }
    }

    static func tabSettings(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "設定"; case .en: "Settings" }
    }

    static func fabLogDrink(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み物を記録"; case .en: "Log a drink" }
    }

    // MARK: - Onboarding

    static func onboardingSaveErrorTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "保存エラー"; case .en: "Save error" }
    }

    static func onboardingLanguageTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "表示言語を選択"; case .en: "Choose display language" }
    }

    static func onboardingLocalOnlyTitle(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "記録はこのiPhoneの中だけに保存されます"
        case .en: "Your records stay on this iPhone."
        }
    }

    static func onboardingLocalOnlyDetail(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "アカウント登録なし・クラウド送信なし"
        case .en: "No account. No cloud upload."
        }
    }

    static func onboardingGoalTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲酒量の目安を設定"; case .en: "Set your alcohol guide" }
    }

    static func onboardingGenderLabel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "目安の基準"; case .en: "Guide basis" }
    }

    static func onboardingGenderMale(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "男性の目安"; case .en: "Male guide" }
    }

    static func onboardingGenderFemale(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "女性の目安"; case .en: "Female guide" }
    }

    static func onboardingGenderCustom(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "自分で設定"; case .en: "Custom" }
    }

    static func onboardingGuidelinesTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "設定する目安"; case .en: "Your guide" }
    }

    static func onboardingDailyGuide(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1日の目安"; case .en: "Daily guide" }
    }

    static func onboardingWeeklyGuide(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1週間の目安"; case .en: "Weekly guide" }
    }

    static func onboardingCustomDailyStepper(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1日の目安（g）"; case .en: "Daily guide (g)" }
    }

    static func onboardingCustomWeeklyStepper(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1週間の目安（g）"; case .en: "Weekly guide (g)" }
    }

    static func onboardingGenderAutoHint(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "選択に応じて目安を設定します。あとから変更できます。"
        case .en: "We’ll set a guide from your choice. You can change it later."
        }
    }

    static func onboardingErrorLanguageNotSelected(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "言語を選択してください。"
        case .en: "Choose a language to continue."
        }
    }

    static func onboardingCoachTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "AI相棒モードを選択"; case .en: "Choose your AI companion mode" }
    }

    static func onboardingCoachDetail(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "記録とペースに寄り添う相棒として、端末内で短い提案を表示します。"
        case .en: "On-device suggestions from a companion tuned to your logs and pace."
        }
    }

    static func onboardingStart(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "始める"; case .en: "Start" }
    }

    // MARK: - Home

    static func homeWeeklySummary(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "今週のまとめ"; case .en: "This week" }
    }

    static func homeStatRestDays(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "休肝日"; case .en: "Dry days" }
    }

    static func homeStatStreak(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "連続日数"; case .en: "Streak" }
    }

    static func homeStatWeekTotal(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "週合計"; case .en: "Week total" }
    }

    static func dayCountSuffix(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "日"; case .en: "d" }
    }

    static func homeTodayDrinks(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "今日の記録"; case .en: "Today's log" }
    }

    static func homeNoDrinksYet(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "まだ記録がありません。\n＋ボタンから追加できます。"
        case .en: "No drinks logged yet.\nTap + to add one."
        }
    }

    static func homePureAlcoholLabel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "今日のアルコール量"; case .en: "Today’s alcohol" }
    }

    static func homeQuickRecord(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ワンタップ記録"; case .en: "Quick log" }
    }

    static func homeFavorites(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "よく飲むドリンク"; case .en: "Favorites" }
    }

    static func homeRecent(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "最近の記録から再利用"; case .en: "Reuse recent entries" }
    }

    static func homeManageFavorites(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "編集"; case .en: "Edit" }
    }

    static func homeNoFavorites(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "記録画面で最大6種類まで登録できます。"
        case .en: "Save up to six favorites from the log screen."
        }
    }

    static func homeLoggedUndo(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "記録しました"; case .en: "Logged" }
    }

    static func homeUndo(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "取り消す"; case .en: "Undo" }
    }

    static func homeSessionTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み会モード"; case .en: "Drinking session" }
    }

    static func homeSessionStart(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み会を開始"; case .en: "Start session" }
    }

    static func homeSessionResume(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "進行中の飲み会を開く"; case .en: "Open active session" }
    }

    static func homeCoachTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "AIコメント"; case .en: "AI comment" }
    }

    static func homeCoachDisclaimer(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "AIは記録にもとづく目安です。医療上の助言ではありません。"
        case .en: "AI comments are based on your logs and are not medical advice."
        }
    }

    static func homeCoachReload(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "更新"; case .en: "Refresh" }
    }

    static func sessionElapsed(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "経過時間"; case .en: "Elapsed" }
    }

    static func sessionHydration(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "水を記録"; case .en: "Log water" }
    }

    static func sessionLogDrink(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ドリンクを記録"; case .en: "Log a drink" }
    }

    static func sessionLastOrder(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ラストオーダー"; case .en: "Last order" }
    }

    static func sessionEnd(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み会を終了"; case .en: "End session" }
    }

    static func sessionLastOrderQuestion(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "ここで一区切りにしますか？"
        case .en: "Make this your stopping point?"
        }
    }

    static func sessionStop(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ここでやめる"; case .en: "Stop here" }
    }

    static func sessionContinue(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "記録を続ける"; case .en: "Keep logging" }
    }

    static func sessionStoppedPraise(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "ここで一区切りにしました。"
        case .en: "Session marked as stopped."
        }
    }

    // MARK: - Calendar

    static func calendarHeroTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "カレンダー"; case .en: "Calendar" }
    }

    static func calendarMonthBlurb(_ monthTitle: String, _ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "\(monthTitle)のまとめ"
        case .en: "Summary for \(monthTitle)"
        }
    }

    static func calendarStatRest(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "休肝日"; case .en: "Dry" }
    }

    static func calendarStatInGoal(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "目安内"; case .en: "Within guide" }
    }

    static func calendarStatOver(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "超過"; case .en: "Over" }
    }

    static func calendarPrevMonthA11y(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "前の月"; case .en: "Previous month" }
    }

    static func calendarNextMonthA11y(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "次の月"; case .en: "Next month" }
    }

    static func calendarWeekTrend(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "今週の推移"; case .en: "Weekly trend" }
    }

    static func calendarLastOrderAchievement(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ラストオーダー達成"; case .en: "Stopped at last order" }
    }

    static func weekdayInitials(_ l: SupportedLanguage) -> [String] {
        switch l {
        case .ja: ["月", "火", "水", "木", "金", "土", "日"]
        case .en: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
        }
    }

    // MARK: - Settings

    static func settingsTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "設定"; case .en: "Settings" }
    }

    static func settingsHeroSubtitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "アプリとデータの管理"; case .en: "App and data" }
    }

    static func settingsLanguagePicker(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "アプリの言語"; case .en: "App language" }
    }

    static func settingsLanguageSection(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "表示言語"; case .en: "Language" }
    }

    static func settingsLanguageFooter(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "アプリ全体の表示言語を切り替えます。"
        case .en: "Changes the display language across the app."
        }
    }

    static func settingsAppInfo(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "アプリ情報"; case .en: "About" }
    }

    static func settingsVersion(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "バージョン"; case .en: "Version" }
    }

    static func settingsSectionGoalsProfile(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "目安"; case .en: "Guides" }
    }

    static func settingsGoalsRow(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1日・1週間の目安"; case .en: "Daily and weekly guides" }
    }

    static func settingsGoalsTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲酒量の目安"; case .en: "Alcohol guides" }
    }

    static func settingsCancel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "キャンセル"; case .en: "Cancel" }
    }

    static func settingsSave(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "保存"; case .en: "Save" }
    }

    static func settingsDailyGoalGrams(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1日の目安（g）"; case .en: "Daily guide (g)" }
    }

    static func settingsWeeklyGoalGrams(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1週間の目安（g）"; case .en: "Weekly guide (g)" }
    }

    static func settingsGoalsHint(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "体調や生活に合わせて、あとからいつでも変更できます。"
        case .en: "You can adjust these anytime to fit your routine."
        }
    }

    static func settingsCoachSection(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "AIコメント"; case .en: "AI comments" }
    }

    static func settingsCoachRow(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "AIコメントのスタイル"; case .en: "AI comment style" }
    }

    static func settingsCoachTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "AIコメント設定"; case .en: "AI comment settings" }
    }

    static func settingsCoachPersonality(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "コメントの雰囲気"; case .en: "Comment tone" }
    }

    static func settingsCoachIntro(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "記録とペースに合わせて表示されるAIコメントの雰囲気を選べます。飲酒を勧めるものではありません。"
        case .en: "Choose the tone for AI comments based on your logs and pace. It will not encourage drinking."
        }
    }

    static func settingsCoachSampleLabel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "例"; case .en: "Example" }
    }

    static func settingsCoachSupportSection(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み会サポート"; case .en: "Session support" }
    }

    static func settingsHydrationInterval(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "水分通知の間隔"; case .en: "Water reminder interval" }
    }

    static func settingsMinutes(_ minutes: Int, _ l: SupportedLanguage) -> String {
        switch l { case .ja: "\(minutes)分"; case .en: "\(minutes) min" }
    }

    static func settingsLastOrderReminder(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ラストオーダー確認を表示"; case .en: "Show last-order check" }
    }

    // MARK: - Settings Notifications

    static func settingsNotificationsSection(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "通知"; case .en: "Notifications" }
    }

    static func settingsNotificationsRow(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "記録リマインダー"; case .en: "Log reminder" }
    }

    static func settingsNotificationsEnabled(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "リマインダーを受け取る"; case .en: "Turn on reminders" }
    }

    static func settingsNotificationsTime(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "通知時刻"; case .en: "Reminder time" }
    }

    static func settingsNotificationsHint(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "指定した時刻に、飲酒量の記録を促します。"
        case .en: "Reminds you to log your drinks at the selected time."
        }
    }

    static func notificationHydrationBody(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "水を飲んで、ペースを整えましょう。"
        case .en: "Take a water break and keep your pace comfortable."
        }
    }

    // MARK: - Settings data & privacy

    static func settingsDataPrivacySection(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "データとプライバシー"; case .en: "Data & privacy" }
    }

    static func settingsPrivacyPolicyRow(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "プライバシーポリシー"; case .en: "Privacy policy" }
    }

    static func settingsDataPrivacyFooter(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "飲酒記録と設定は、この端末内だけに保存されます。"
        case .en: "Drink logs and settings stay only on this device."
        }
    }

    /// DESIGN.md「設定画面」・SPEC 免責（12pt 相当で表示）
    static func settingsMedicalDisclaimer(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja:
            "本アプリは医療アドバイスや診断を提供するものではありません。表示される数値は目安であり、健康上の判断は医師等の専門家にご相談ください。"
        case .en:
            "This app is not medical advice or a diagnostic tool. Numbers are for reference only; consult a qualified professional for health decisions."
        }
    }

    // MARK: - Drink log sheet

    static func drinkLogTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み物を記録"; case .en: "Log a drink" }
    }

    static func drinkLogEditTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "記録を編集"; case .en: "Edit drink log" }
    }

    static func drinkLogSave(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "記録する"; case .en: "Log drink" }
    }

    static func drinkLogUpdate(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "変更を保存"; case .en: "Save changes" }
    }

    static func drinkLogDeleteRecord(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "この記録を削除"; case .en: "Delete this log" }
    }

    static func drinkLogClose(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "閉じる"; case .en: "Close" }
    }

    static func drinkLogSaveFailed(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "保存できませんでした"; case .en: "Couldn't save" }
    }

    static func drinkLogAdjust(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "内容を調整"; case .en: "Details" }
    }

    static func drinkLogVolume(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1杯の量"; case .en: "Volume per drink" }
    }

    static func drinkLogDrinksCount(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "杯数"; case .en: "Number of drinks" }
    }

    static func drinkLogAbv(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "度数(%)"; case .en: "ABV (%)" }
    }

    static func drinkLogPureAlcohol(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "純アルコール量"; case .en: "Pure alcohol" }
    }

    static func drinkLogAddFavorite(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "よく飲むドリンクに登録"; case .en: "Save as favorite" }
    }

    static func drinkLogFavoritesLimit(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "よく飲むドリンクは6種類まで登録できます。"
        case .en: "You can keep up to six favorites."
        }
    }

    static func drinkLogPresetApplied(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "フォームに反映しました"; case .en: "Applied to the form" }
    }

}
