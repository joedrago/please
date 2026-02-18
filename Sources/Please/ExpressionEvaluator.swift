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
        let expr = trimmed.replacingOccurrences(of: "^", with: "**")

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

        if doubleVal == doubleVal.rounded(.towardZero),
           doubleVal >= Double(Int.min), doubleVal <= Double(Int.max)
        {
            return String(Int(doubleVal))
        }
        return String(format: "%.10g", doubleVal)
    }
}
