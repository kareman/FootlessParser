//
// Created by Gordon Fontenot (https://github.com/gfontenot) on 22.01.15.
// From https://github.com/thoughtbot/Runes/blob/a2d22e2a761d4284deb30318930bd7ab3382c47f/Source/Result.swift
//

import Result

/**
map a function over a result

- If the value is .Failure, the function will not be evaluated and this will return the failure
- If the value is .Success, the function will be applied to the unwrapped value

- parameter f: A transformation function from type T to type U
- parameter a: A value of type Result<T, E>

- returns: A value of type Result<U, E>
*/
public func <^> <T, U, E> (f: T -> U, a: Result<T, E>) -> Result<U, E> {
	return a.map(f)
}

/**
apply a function from a result to a result

- If the function is .Failure, the function will not be evaluated and this will return the error from the function result
- If the value is .Failure, the function will not be evaluated and this will return the error from the passed result value
- If both the value and the function are .Success, the unwrapped function will be applied to the unwrapped value

- parameter f: A result containing a transformation function from type T to type U
- parameter a: A value of type Result<T, E>

- returns: A value of type Result<U, E>
*/
public func <*> <T, U, E> (f: Result<(T -> U), E>, a: Result<T, E>) -> Result<U, E> {
	return a.apply(f)
}

/**
Wrap a value in a minimal context of .Success

- parameter a: A value of type T

- returns: The provided value wrapped in .Success
*/
public func pure <T, E> (a: T) -> Result<T, E> {
	return .Success(a)
}

extension Result {
	/**
	apply a function from a result to self

	- If the function is .Failure, the function will not be evaluated and this will return the error from the function result
	- If self is .Failure, the function will not be evaluated and this will return the error from self
	- If both self and the function are .Success, the unwrapped function will be applied to self

	- parameter f: A result containing a transformation function from type T to type U

	- returns: A value of type Result<U, E>
	*/
	func apply <U> (f: Result<(T -> U), Error>) -> Result<U, Error> {
		return f >>- { $0 <^> self }
	}
}
