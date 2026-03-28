import Foundation

/// UI 文言（`SupportedLanguage` 連動）。String Catalog 本格導入までの集中管理。
enum AppCopy {
    // MARK: - Shell

    static func tabHome(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ホーム"; case .en: "Home" }
    }

    static func tabCalendar(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "カレンダー"; case .en: "Calendar" }
    }

    static func tabFeed(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "みんな"; case .en: "Feed" }
    }

    static func tabSettings(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "設定"; case .en: "Settings" }
    }

    static func fabLogDrink(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "飲み物を記録"; case .en: "Log a drink" }
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

    static func homeFeedPreview(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "みんなの様子"; case .en: "Community" }
    }

    static func homeSeeMore(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "もっと見る →"; case .en: "See more →" }
    }

    static func homeNicknameFallback(_ l: SupportedLanguage) -> String {
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

    // MARK: - Feed

    static func feedHeroTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "🌍 みんなの記録"; case .en: "🌍 Everyone's log" }
    }

    static func feedHeroSubtitle(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "世界中の仲間と励まし合おう！"
        case .en: "Cheer each other on around the world!"
        }
    }

    static func feedNavTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "みんな"; case .en: "Feed" }
    }

    static func feedEmpty(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "まだ投稿がありません"; case .en: "No posts yet" }
    }

    static func feedBlockAlertTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ブロックしますか？"; case .en: "Block this user?" }
    }

    static func feedCancel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "キャンセル"; case .en: "Cancel" }
    }

    static func feedBlock(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ブロック"; case .en: "Block" }
    }

    static func feedBlockConfirmNamed(_ name: String, _ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "\(name) をブロックします。フィードに表示されなくなります。"
        case .en: "Block \(name)? They won't appear in your feed."
        }
    }

    static func feedBlockConfirmAnonymous(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "このユーザーをブロックします。フィードに表示されなくなります。"
        case .en: "Block this user? They won't appear in your feed."
        }
    }

    static func feedReactionAlertTitle(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "リアクション"; case .en: "Reaction" }
    }

    static func feedReactionFailed(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "リアクションを送れませんでした"; case .en: "Couldn't send reaction" }
    }

    static func feedFilterAll(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "すべて"; case .en: "All" }
    }

    static func feedFilterJapanese(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "🇯🇵日本語"; case .en: "🇯🇵 Japanese" }
    }

    static func feedFilterEnglish(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "🇺🇸 EN"; case .en: "🇺🇸 English" }
    }

    static func feedCardBlockUser(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "このユーザーをブロック"; case .en: "Block user" }
    }

    static func feedCardReportPost(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "この投稿を通報"; case .en: "Report post" }
    }

    static func feedReportInappropriate(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "不適切な内容"; case .en: "Inappropriate" }
    }

    static func feedReportSpam(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "スパム"; case .en: "Spam" }
    }

    static func feedReportHarassment(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "ハラスメント"; case .en: "Harassment" }
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

    static func settingsPlaceholder(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "飲酒目標・通知・データのエクスポートなどは、次の段階でここに追加します。"
        case .en: "Goals, notifications, and export will land here in a later phase."
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

    // MARK: - HomeViewLite（診断用）

    static func liteWeekTotalLabel(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "週合計"; case .en: "Week total" }
    }

    static func liteMoreCount(_ n: Int, _ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "…他 \(n)件"
        case .en: "…+\(n) more"
        }
    }

    static func liteTodayRecordsLine(_ count: Int, _ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "今日の記録: \(count)件"
        case .en: "Today: \(count) \(count == 1 ? "entry" : "entries")"
        }
    }

    static func liteFeedPlaceholder(_ l: SupportedLanguage) -> String {
        switch l {
        case .ja: "公開準備中（もっと見る →）"
        case .en: "Coming soon (See more →)"
        }
    }

    static func liteLogButton(_ l: SupportedLanguage) -> String {
        switch l { case .ja: "＋ 飲み物を記録"; case .en: "＋ Log a drink" }
    }
}
