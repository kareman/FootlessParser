# FootlessParser

FootlessParser is a simple and pretty naive implementation of a parser combinator in Swift. It enables infinite lookahead, non-ambiguous parsing with error reporting.

Also check out [a series of blog posts about the development](http://blog.nottoobadsoftware.com/footlessparser/) and [documentation from the source code](http://kareman.github.io/FootlessParser/).

### Introduction

In short, FootlessParser lets you define parsers like this:

```swift
let parser = function1 <^> parser1 <*> parser2 <|> parser3
```

`function1` and `parser3` return the same type.

`parser` will pass the input to `parser1` followed by `parser2`, pass their results to `function1` and return its result. If that fails it will pass the original input to `parser3` and return its result.

### Example

#### [CSV](http://www.computerhope.com/jargon/c/csv.htm) parser

```swift
let delimiter = "," as Character
let quote = "\"" as Character
let newline = "\n" as Character

let cell = char(quote) *> zeroOrMore(not(quote)) <* char(quote)
	<|> zeroOrMore(noneOf([delimiter, newline]))

let row = extend <^> cell <*> zeroOrMore( char(delimiter) *> cell ) <* char(newline)
let csvparser = zeroOrMore(row)
```

Here a cell (or field) either:

- begins with a ", then contains anything, including commas, tabs and newlines, and ends with a " (both quotes are discarded) 
- or is unquoted and contains anything but a comma or a newline.

Each row then consists of one or more cells, separated by commas and ended by a newline. The `extend` function joins the cells together into an array. 
Finally the `csvparser` collects zero or more rows into an array.

To perform the actual parsing:

```swift
let result = parse(csvparser, csvtext)
if let output = result.value {
	// output is an array of all the rows, 
	// where each row is an array of all its cells.
} else if let error = result.error {
	println(error)
}
```

The `parse` function returns a [Result](https://github.com/antitypical/Result) which if successful contains the output from the parser, or in case of failure contains the error.

### Installation

#### Using [Carthage](https://github.com/Carthage/Carthage)

```
github "kareman/FootlessParser"
```

Then run `carthage update`.

Follow the current instructions in [Carthage's README][carthage-installation] for up to date installation instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application
