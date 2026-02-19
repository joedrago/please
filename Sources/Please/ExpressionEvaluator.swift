import Foundation
import ObjCExceptionCatcher

enum ExpressionEvaluator {
    private static let allowedCharacters = CharacterSet(charactersIn: "0123456789+-*/^(). ")

    static func evaluate(_ input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        // Only allow digits, operators, parens, decimal points, spaces
        guard trimmed.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else {
            return nil
        }

        // Must contain at least one digit and one operator
        let hasDigit = trimmed.contains(where: { $0.isNumber })
        let hasOperator = trimmed.contains(where: { "+-*/^".contains($0) })
        guard hasDigit, hasOperator else { return nil }

        // Replace ^ with ** for NSExpression power operator
        var expr = trimmed.replacingOccurrences(of: "^", with: "**")

        // Promote all integer literals to doubles so NSExpression uses
        // floating-point arithmetic (avoids surprising integer truncation)
        expr = expr.replacingOccurrences(
            of: "(?<!\\.)\\b(\\d+)(?!\\.\\d)\\b",
            with: "$1.0",
            options: .regularExpression
        )

        // NSExpression throws ObjC exceptions on malformed input
        var result: AnyObject?
        let success = ObjCTryEval({
            NSExpression(format: expr).expressionValue(with: nil, context: nil) as AnyObject
        }, &result)

        guard success, let number = result as? NSNumber else { return nil }
        return formatResult(number)
    }

    private static func formatResult(_ number: NSNumber) -> String {
        let doubleVal = number.doubleValue
        guard doubleVal.isFinite else { return "Error" }

        let formatted = String(doubleVal)
        if formatted.hasSuffix(".0") {
            return String(formatted.dropLast(2))
        }
        return formatted
    }
}
