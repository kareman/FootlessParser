//
// StringParser.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import Result
import Runes


/** Apply character parser once, then repeat until it fails. Returns a string. */
public func oneOrMore <T> (p: Parser<T,Character>) -> Parser<T,String> {
	return extend <^> p <*> optional( lazy(oneOrMore(p)), otherwise: "" )
}

/** Repeat character parser until it fails. Returns a string. */
public func zeroOrMore <T> (p: Parser<T,Character>) -> Parser<T,String> {
	return optional( oneOrMore(p), otherwise: "" )
}
