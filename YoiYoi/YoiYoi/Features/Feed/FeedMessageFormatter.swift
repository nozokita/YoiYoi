import Foundation

/// フィード本文（`FeedPost` + 言語コード）。テンプレは MVP 固定。
enum FeedMessageFormatter {
    static func message(for post: FeedPost) -> String {
        let lang = post.language
        let isJa = lang.hasPrefix("ja")
        let drinkCount = post.drinks.count
        let pct = Int(post.percentage.rounded())

        switch post.type {
        case .goalMet:
            return goalMet(isJa: isJa, drinkCount: drinkCount, pct: pct, variant: post.messageVariant)
        case .restDay:
            return restDay(isJa: isJa, streak: post.streakDays, variant: post.messageVariant)
        case .overGoal:
            return overGoal(isJa: isJa, actual: post.actualGrams, goal: post.goalGrams, pct: pct, variant: post.messageVariant)
        case .weeklyAchieved:
            return weekly(isJa: isJa, pct: pct, variant: post.messageVariant)
        }
    }

    private static func goalMet(isJa: Bool, drinkCount: Int, pct: Int, variant: Int) -> String {
        let v = variant % 5
        if isJa {
            switch v {
            case 0: return "目標内！🍺×\(drinkCount)杯 — \(pct)%をクリア 🎉"
            case 1: return "今日もバランスよく。純アル \(pct)%のペースです ✨"
            case 2: return "ちょうどいい量。\(drinkCount)杯で \(pct)%達成！"
            case 3: return "ナイスコントロール 🍀 \(pct)%"
            default: return "目標内キープ中。\(pct)%の一日 🌿"
            }
        } else {
            switch v {
            case 0: return "On track! \(drinkCount) drink(s) — \(pct)% of goal 🎉"
            case 1: return "Balanced today at \(pct)% ✨"
            case 2: return "Nice pace — \(pct)% with \(drinkCount) drink(s)."
            case 3: return "Great control 🍀 \(pct)%"
            default: return "Staying within goal: \(pct)% today 🌿"
            }
        }
    }

    private static func restDay(isJa: Bool, streak: Int, variant: Int) -> String {
        let v = variant % 5
        if isJa {
            switch v {
            case 0: return "休肝日！\(streak)日連続達成 🌿"
            case 1: return "今日はお休み。ストリーク \(streak) 日 🍵"
            case 2: return "休肝デー、身体にサンキュー ☀️（\(streak)日）"
            case 3: return "ゼログラムの日。\(streak)日連続！"
            default: return "休肝日をキープ中 \(streak) 日連続 💚"
            }
        } else {
            switch v {
            case 0: return "Rest day! \(streak)-day streak 🌿"
            case 1: return "Zero today — streak \(streak) 🍵"
            case 2: return "Alcohol-free day. Thanks, body! (\(streak)d)"
            case 3: return "0g day — \(streak) days in a row."
            default: return "Keeping rest days — \(streak)-day streak 💚"
            }
        }
    }

    private static func overGoal(isJa: Bool, actual: Double, goal: Double, pct: Int, variant: Int) -> String {
        let v = variant % 5
        let a = String(format: "%.0f", actual)
        let g = String(format: "%.0f", goal)
        if isJa {
            switch v {
            case 0: return "オーバー…\(a)g / \(g)g（+\(pct)%）💪"
            case 1: return "今日は少し多め。\(a)g / \(g)g"
            case 2: return "目標を超えました \(a)g / \(g)g — 明日はゆるりと 🌙"
            case 3: return "\(a)g / \(g)g。気づけたのがえらい！"
            default: return "ペース調整のチャンス。\(a)g / \(g)g"
            }
        } else {
            switch v {
            case 0: return "Over goal: \(a)g / \(g)g (+\(pct)%) 💪"
            case 1: return "A bit high today — \(a)g / \(g)g."
            case 2: return "Past goal at \(a)g / \(g)g — reset tomorrow 🌙"
            case 3: return "\(a)g / \(g)g. Noticing it matters!"
            default: return "Room to rebalance: \(a)g / \(g)g"
            }
        }
    }

    private static func weekly(isJa: Bool, pct: Int, variant: Int) -> String {
        let v = variant % 5
        if isJa {
            switch v {
            case 0: return "週目標クリア！\(pct)% の一週間 🌟"
            case 1: return "今週もまとまった達成率 \(pct)% ✨"
            case 2: return "週の締め、目標内でフィニッシュ（\(pct)%）"
            case 3: return "ウィークリー達成おめでとう 🎊 \(pct)%"
            default: return "一週間おつかれさま。\(pct)%で安定 🌿"
            }
        } else {
            switch v {
            case 0: return "Weekly goal met! \(pct)% week 🌟"
            case 1: return "Solid week at \(pct)% ✨"
            case 2: return "Week closed within goal (\(pct)%)."
            case 3: return "Weekly win 🎊 \(pct)%"
            default: return "Nice week — steady at \(pct)% 🌿"
            }
        }
    }
}
