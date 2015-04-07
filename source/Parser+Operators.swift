//
// Parser+Operators.swift
// FootlessParser
//
// Created by Kåre Morstøl on 31.03.15.
// Copyright (c) 2015 NotTooBad Software. All rights reserved.
//

import LlamaKit
import Runes


public func >>- <T,A,B> (p: Parser<T,A>, f: A -> Parser<T,B>) -> Parser<T,B> {
	return Parser { input in
		p.parse(input) >>- { f($0.output).parse($0.nextinput) }
	}
}

/**
	Wrap a value in a minimal context of Parser

	:param: a A value of type A

	:returns: A parser which ignores the input and returns 'a'.
*/
public func pure <A> (a: A) -> Parser<A,A> {
	return Parser { input in success((output:a, nextinput: input))	}
}
