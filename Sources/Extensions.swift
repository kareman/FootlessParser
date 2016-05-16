//
// Extensions.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2016 Bouke Haarsma. All rights reserved.
//

import Foundation

func == <T: Equatable> (lhs: AnyCollection<T>, rhs: AnyCollection<T>) -> Bool {
    guard lhs.count == rhs.count else { return false }
    for (lhs, rhs) in zip(lhs, rhs) {
        guard lhs == rhs else { return false }
    }
    return true
}
extension AnyCollection where Element: Equatable { }
