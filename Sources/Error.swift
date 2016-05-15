import Foundation

public enum Error: ErrorProtocol {
    case EOF
    case Mismatch(String, String)
    case NegativeCount
}

extension Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .EOF: return "Unexpected EOF"
        case let .Mismatch(expected, actual): return "Expected \(expected), actual \(actual)"
        case .NegativeCount: return "Cannot expect negative count"
        }
    }
}

public func == (lhs: Error, rhs: Error) -> Bool {
    switch (lhs, rhs) {
    case (.EOF, .EOF): return true
    case let(.Mismatch(e1, a1), .Mismatch(e2, a2)) where e1 == e2 && a1 == a2: return true
    case (.NegativeCount, .NegativeCount): return true
    default: return false
    }
}

extension Error: Equatable {}
