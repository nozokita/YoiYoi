import Foundation

/// UI 文言（`SupportedLanguage` 連動）。String Catalog 本格導入までの集中管理。
enum AppCopy {
    // MARK: - Common

    static func commonBack(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "戻る"; case .en: "Back" }
    }

    static func commonNext(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "つぎへ"; case .en: "Next" }
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
        switch l { case .ja: "言語を選んでね"; case .en: "Choose a language" }
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
        switch l { case .ja: "あなたの目標を設定"; case .en: "Set your goals" }
    }

    static func onboardingGenderLabel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "性別"; case .en: "Gender" }
    }

    static func onboardingGenderMale(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "男性 ♂"; case .en: "Male ♂" }
    }

    static func onboardingGenderFemale(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "女性 ♀"; case .en: "Female ♀" }
    }

    static func onboardingGenderCustom(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "カスタム"; case .en: "Custom" }
    }

    static func onboardingGuidelinesTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "厚労省ガイドライン"; case .en: "Guidelines" }
    }

    static func onboardingDailyGuide(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1日の目安"; case .en: "Daily" }
    }

    static func onboardingWeeklyGuide(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1週間の目安"; case .en: "Weekly" }
    }

    static func onboardingCustomDailyStepper(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1日の目安（g）"; case .en: "Daily goal (g)" }
    }

    static func onboardingCustomWeeklyStepper(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1週間の目安（g）"; case .en: "Weekly goal (g)" }
    }

    static func onboardingGenderAutoHint(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "性別に応じて自動変更（カスタムでは ±5g / ±35g）"
        case .en: "Auto-set by gender (Custom: ±5g / ±35g)"
        }
    }

    static func onboardingErrorLanguageNotSelected(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "言語が選択されていません。言語選択の画面に戻って選んでください。"
        case .en: "No language selected. Go back and choose one."
        }
    }

    static func onboardingCoachTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "コーチの話し方を選ぶ"; case .en: "Choose your coach style" }
    }

    static func onboardingCoachDetail(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "端末内で、無理しないペースを応援するひとことを表示します。"
        case .en: "On-device encouragement to help you keep a comfortable pace."
        }
    }

    static func onboardingStart(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "はじめる"; case .en: "Start" }
    }

    // MARK: - Home

    static func homeGreeting(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "おつかれさま"; case .en: "Cheers" }
    }

    static func homeWeeklySummary(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "今週のまとめ"; case .en: "This week" }
    }

    static func homeStatRestDays(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "休肝日"; case .en: "Dry days" }
    }

    static func homeStatStreak(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "連続"; case .en: "Streak" }
    }

    static func homeStatWeekTotal(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "週合計"; case .en: "Week total" }
    }

    static func dayCountSuffix(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "日"; case .en: "d" }
    }

    static func homeTodayDrinks(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "今日のドリンク"; case .en: "Today's drinks" }
    }

    static func homeNoDrinksYet(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "まだ記録がないよ。\n＋ボタンで記録してね！"
        case .en: "Nothing logged yet.\nTap + to add a drink!"
        }
    }

    static func homePureAlcoholLabel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "今日の純アルコール"; case .en: "Today's pure alcohol" }
    }

    static func homeQuickRecord(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ワンタップ記録"; case .en: "One-tap log" }
    }

    static func homeFavorites(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "よく飲むドリンク"; case .en: "Favorites" }
    }

    static func homeRecent(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "前回の内容を再利用"; case .en: "Recent combinations" }
    }

    static func homeManageFavorites(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "編集"; case .en: "Edit" }
    }

    static func homeNoFavorites(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "記録画面から最大6種類を登録できます。"
        case .en: "Add up to six from the log screen."
        }
    }

    static func homeLoggedUndo(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "記録しました"; case .en: "Logged" }
    }

    static func homeUndo(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "取り消す"; case .en: "Undo" }
    }

    static func homeSessionTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み会モード"; case .en: "Session mode" }
    }

    static func homeSessionStart(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み会をはじめる"; case .en: "Start a session" }
    }

    static func homeSessionResume(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "進行中の飲み会を開く"; case .en: "Open active session" }
    }

    static func homeCoachTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ローカルコーチ"; case .en: "Local coach" }
    }

    static func homeCoachReload(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "更新"; case .en: "Refresh" }
    }

    static func sessionElapsed(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "経過時間"; case .en: "Elapsed" }
    }

    static func sessionHydration(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "お水を飲んだ"; case .en: "Logged water" }
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
        case .ja: "このまま一区切りにしますか？"
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
        case .ja: "ここで止められたね。おつかれさま！"
        case .en: "You chose to stop here. Nicely done."
        }
    }

    // MARK: - Calendar

    static func calendarHeroTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "カレンダー"; case .en: "Calendar" }
    }

    static func calendarMonthBlurb(_ monthTitle: String, _ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "\(monthTitle)のまとめ"
        case .en: "\(monthTitle) · summary"
        }
    }

    static func calendarStatRest(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "休肝日"; case .en: "Dry" }
    }

    static func calendarStatInGoal(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "目標内"; case .en: "On track" }
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
        switch l { case .ja: "今週の推移"; case .en: "This week" }
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
        switch l { case .ja: "アプリとデータの管理"; case .en: "App & data" }
    }

    static func settingsLanguagePicker(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "アプリの言語"; case .en: "App language" }
    }

    static func settingsLanguageSection(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "表示言語"; case .en: "Language" }
    }

    static func settingsLanguageFooter(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "ホームや記録シートの表記が切り替わります。"
        case .en: "Updates labels on Home and the log sheet."
        }
    }

    static func settingsAppInfo(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "アプリ情報"; case .en: "About" }
    }

    static func settingsVersion(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "バージョン"; case .en: "Version" }
    }

    static func settingsSectionGoalsProfile(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "目標・プロフィール"; case .en: "Goals & profile" }
    }

    static func settingsGoalsRow(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲酒目標（1日・1週間）"; case .en: "Daily & weekly goals" }
    }

    static func settingsGoalsTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲酒目標"; case .en: "Drinking goals" }
    }

    static func settingsCancel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "キャンセル"; case .en: "Cancel" }
    }

    static func settingsSave(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "保存"; case .en: "Save" }
    }

    static func settingsDailyGoalGrams(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1日の目標（g）"; case .en: "Daily goal (g)" }
    }

    static func settingsWeeklyGoalGrams(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "1週間の目標（g）"; case .en: "Weekly goal (g)" }
    }

    static func settingsGoalsHint(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "厚労省の目安を参考に、自分に合った値に調整できます。"
        case .en: "Tune these to what works for you."
        }
    }

    static func settingsCoachSection(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "コーチと飲み会モード"; case .en: "Coach & sessions" }
    }

    static func settingsCoachRow(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "コーチ・水分通知の設定"; case .en: "Coach & hydration settings" }
    }

    static func settingsCoachTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "コーチ設定"; case .en: "Coach settings" }
    }

    static func settingsCoachPersonality(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "話し方"; case .en: "Style" }
    }

    static func settingsHydrationInterval(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "水分通知の間隔"; case .en: "Hydration interval" }
    }

    static func settingsMinutes(_ minutes: Int, _ l: SupportedLanguage) -> String {
        switch l { case .ja: "\(minutes)分"; case .en: "\(minutes) min" }
    }

    static func settingsLastOrderReminder(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ラストオーダー確認を表示"; case .en: "Show last-order prompt" }
    }

    // MARK: - Settings Notifications

    static func settingsNotificationsSection(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "通知"; case .en: "Notifications" }
    }

    static func settingsNotificationsRow(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲酒記録リマインダー"; case .en: "Drink log reminder" }
    }

    static func settingsNotificationsEnabled(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "リマインダーを受け取る"; case .en: "Receive reminders" }
    }

    static func settingsNotificationsTime(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "通知時刻"; case .en: "Reminder time" }
    }

    static func settingsNotificationsHint(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "毎日この時間に、今日のペースを記録して振り返るようお知らせします。"
        case .en: "We'll remind you to log and reflect on today's pace at this time."
        }
    }

    static func notificationHydrationBody(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "お水でひと息。無理しないペースで楽しもう。"
        case .en: "Water break time. Keep a comfortable pace."
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
        switch l { case .ja: "のみものを記録"; case .en: "Log a drink" }
    }

    static func drinkLogSave(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "記録する"; case .en: "Save" }
    }

    static func drinkLogClose(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "閉じる"; case .en: "Close" }
    }

    static func drinkLogSaveFailed(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "保存できませんでした"; case .en: "Couldn't save" }
    }

    static func drinkLogAdjust(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "調整"; case .en: "Adjust" }
    }

    static func drinkLogDrinksCount(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "杯数"; case .en: "Drinks" }
    }

    static func drinkLogAbv(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "度数(%)"; case .en: "ABV (%)" }
    }

    static func drinkLogPureAlcohol(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "純アルコール量"; case .en: "Pure alcohol" }
    }

    static func drinkLogAddFavorite(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "よく飲むドリンクに追加"; case .en: "Add to favorites" }
    }

    static func drinkLogFavoritesLimit(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "よく飲むドリンクは6種類まで登録できます。"
        case .en: "You can keep up to six favorites."
        }
    }

    static func drinkLogPresetApplied(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "内容をフォームに反映しました"; case .en: "Filled into the form" }
    }

}
