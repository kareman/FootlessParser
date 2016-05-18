import Foundation

public enum Error: ErrorProtocol {
    case NegativeCount
}


public enum ParseError<T>: ErrorProtocol {
    case Mismatch(AnyCollection<T>, String, String)
}

extension ParseError: CustomStringConvertible {
    public var description: String {
        switch self {
        case let .Mismatch(remainder, expected, actual): return "Expected \(expected), actual \(actual) at position -\(remainder.count)"
        }
    }
}
