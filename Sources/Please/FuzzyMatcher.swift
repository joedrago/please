import Foundation

enum FuzzyMatcher {
    struct Match {
        let app: AppInfo
        let score: Int
    }

    static func score(query: String, target: String) -> Int? {
        let queryLower = query.lowercased()
        let targetLower = target.lowercased()

        guard !queryLower.isEmpty else { return 0 }

        // Check that all query characters exist in order in target
        var queryIndex = queryLower.startIndex
        var targetIndex = targetLower.startIndex

        while queryIndex < queryLower.endIndex, targetIndex < targetLower.endIndex {
            if queryLower[queryIndex] == targetLower[targetIndex] {
                queryIndex = queryLower.index(after: queryIndex)
            }
            targetIndex = targetLower.index(after: targetIndex)
        }

        // Not all query characters matched
        guard queryIndex == queryLower.endIndex else { return nil }

        // Calculate score
        var score = 0
        var consecutive = 0
        queryIndex = queryLower.startIndex
        targetIndex = targetLower.startIndex
        var prevTargetIndex: String.Index?

        while queryIndex < queryLower.endIndex, targetIndex < targetLower.endIndex {
            if queryLower[queryIndex] == targetLower[targetIndex] {
                score += 1

                // Bonus for consecutive matches
                if let prev = prevTargetIndex, targetLower.index(after: prev) == targetIndex {
                    consecutive += 1
                    score += consecutive * 3
                } else {
                    consecutive = 0
                }

                // Bonus for matching at start of target
                if targetIndex == targetLower.startIndex {
                    score += 10
                }

                // Bonus for matching after separator (space, hyphen)
                if targetIndex > targetLower.startIndex {
                    let prevChar = targetLower[targetLower.index(before: targetIndex)]
                    if prevChar == " " || prevChar == "-" || prevChar == "_" {
                        score += 8
                    }
                }

                // Bonus for case match (original strings)
                let queryChar = query[query.index(
                    query.startIndex,
                    offsetBy: queryLower.distance(from: queryLower.startIndex, to: queryIndex)
                )]
                let targetChar = target[target.index(
                    target.startIndex,
                    offsetBy: targetLower.distance(from: targetLower.startIndex, to: targetIndex)
                )]
                if queryChar == targetChar, queryChar.isUppercase {
                    score += 2
                }

                prevTargetIndex = targetIndex
                queryIndex = queryLower.index(after: queryIndex)
            }
            targetIndex = targetLower.index(after: targetIndex)
        }

        // Bonus for shorter names (more relevant match)
        let lengthPenalty = max(0, targetLower.count - queryLower.count)
        score -= lengthPenalty / 3

        // Bonus for prefix match
        if targetLower.hasPrefix(queryLower) {
            score += 15
        }

        return score
    }

    static func filter(
        apps: [AppInfo],
        query: String,
        fuzzy: Bool = true,
        lowPriorityIDs: Set<String> = [],
        highPriorityIDs: Set<String> = [],
        aliases: [String: String] = [:]
    ) -> [Match] {
        guard !query.isEmpty else {
            return apps.map { Match(app: $0, score: 0) }
        }

        return apps.compactMap { app in
            let alias = aliases[app.id]
            if fuzzy {
                let nameScore = score(query: query, target: app.name)
                let aliasScore = alias.flatMap { score(query: query, target: $0) }
                if let best = [nameScore, aliasScore].compactMap({ $0 }).max() {
                    return Match(app: app, score: best)
                }
            } else {
                let queryLower = query.lowercased()
                if app.name.lowercased().hasPrefix(queryLower) ||
                    (alias?.lowercased().hasPrefix(queryLower) ?? false)
                {
                    return Match(app: app, score: 0)
                }
            }
            return nil
        }.sorted { a, b in
            let aHigh = highPriorityIDs.contains(a.app.id)
            let bHigh = highPriorityIDs.contains(b.app.id)
            if aHigh != bHigh { return aHigh }
            let aLow = lowPriorityIDs.contains(a.app.id)
            let bLow = lowPriorityIDs.contains(b.app.id)
            if aLow != bLow { return !aLow }
            return a.score > b.score
        }
    }
}
