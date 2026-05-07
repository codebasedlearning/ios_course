// (C) Alexander Voß, a.voss@fh-aachen.de, info@codebasedlearning.dev

import Foundation

func toValidUnitStr(_ value: Int?, _ unit: String) -> String {
    guard let value else { return "-" }
    return "\(value)\(unit)"
}
