//
// Parsers.swift
// FootlessParser
//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2016 Bouke Haarsma. All rights reserved.

import Foundation

/**
 Parser that matches all the whitespace characters.

 Matches the character set containing the characters in Unicode General 
 Category Zs and CHARACTER TABULATION (U+0009).
 */
public let whitespace = char(CharacterSet.whitespaces, name: "whitespace")

/**
 Parser that matches all the newline characters.

 Matches the character set containing the newline characters (U+000A ~ U+000D, 
 U+0085, U+2028, and U+2029).
 */
public let newline = char(CharacterSet.newlines, name: "newline")

/**
 Parser that matches all the whitespace and newline characters.

 Matches the character set containing characters in Unicode General Category 
 Z*, U+000A ~ U+000D, and U+0085.
 */
public let whitespacesOrNewline = char(CharacterSet.whitespacesAndNewlines, name: "whitespacesOrNewline")

/**
 Parser that matches all the decimal digit characters.

 Matches the character set containing the characters in the category of Decimal
 Numbers.
 */
public let digit = char(CharacterSet.decimalDigits, name: "digit")

/**
 Parser that matches all the alphanumeric characters.

 Matches the character set containing the characters in Unicode General 
 Categories L*, M*, and N*.
*/
public let alphanumeric = char(CharacterSet.alphanumerics, name: "alphanumeric")
