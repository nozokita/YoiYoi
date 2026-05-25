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
        switch l { case .ja: "カスタム ⚙"; case .en: "Custom ⚙" }
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

    // MARK: - Home

    static func homeGreeting(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "おつかれさま！🍺"; case .en: "Cheers! 🍺" }
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

    // MARK: - Calendar

    static func calendarHeroTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "📅 カレンダー"; case .en: "📅 Calendar" }
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
        case .ja: "毎日この時間に「今日は飲んだ？ 記録しよう🍺」とお知らせします。"
        case .en: "We'll gently ask \"Did you drink today?\" at this time every day."
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
            "⚠️ 本アプリは医療アドバイスや診断を提供するものではありません。表示される数値は目安であり、健康上の判断は医師等の専門家にご相談ください。"
        case .en:
            "⚠️ This app is not medical advice or a diagnostic tool. Numbers are for reference only; consult a qualified professional for health decisions."
        }
    }

    // MARK: - Drink log sheet

    static func drinkLogTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "🍺 のみものを記録"; case .en: "🍺 Log a drink" }
    }

    static func drinkLogSave(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "🍺 記録する！"; case .en: "🍺 Save" }
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

}
