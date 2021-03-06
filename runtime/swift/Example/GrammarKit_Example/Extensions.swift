//
// The MIT License (MIT)
//
// Copyright © 2020 NoodleOfDeath. All rights reserved.
// NoodleOfDeath
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import CoreImage

// MARK: - Path Component Concatentation Infix Operator

infix operator +/ : AdditionPrecedence

// MARK: - Optional Assignment Operator

infix operator ?= : AssignmentPrecedence

// MARK: - Exponentiation Infix Operator

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

// MARK: - Optional Wrapper Assignment Operator Methods

///
///
/// - Parameters:
///     - lhs:
///     - rhs:
func ?= <T>(lhs: inout T, rhs: T?) {
    guard let rhs = rhs else { return }
    lhs = rhs
}

///
///
/// - Parameters:
///     - lhs:
///     - rhs:
func ?= <T>(lhs: inout T?, rhs: T?) {
    guard let rhs = rhs else { return }
    lhs = rhs
}

// MARK: - Numeric-Boolean Math Operator Methods

///
///
/// - Parameters:
///     - lhs:
///     - rhs:
/// - Returns:
func + <NumericType: Numeric>(lhs: NumericType, rhs: Bool) -> NumericType {
    return lhs + (rhs ? 1 : 0)
}

///
///
/// - Parameters:
///     - lhs:
///     - rhs:
/// - Returns:
func + <NumericType: Numeric>(lhs: Bool, rhs: NumericType) -> NumericType {
    return (lhs ? 1 : 0) + rhs
}

// MARK: - CGFloat Extension
extension CGFloat {
    
    /// Legacy alias for `leastNormalMagnitude`.
    static var min: CGFloat {  return leastNormalMagnitude }
    
    /// Legacy alias for `greatestFiniteMagnitude`.
    static var max: CGFloat { return greatestFiniteMagnitude }
    
}

// MARK: - Dictiopnary Extension
extension Dictionary {

    static func + (lhs: Dictionary<Key, Value>, rhs: Dictionary<Key, Value>) -> Dictionary<Key, Value> {
        var dict = lhs
        rhs.forEach { dict[$0.key] = $0.value }
        return dict
    }

    static func += (lhs: inout Dictionary<Key, Value>, rhs: Dictionary<Key, Value>) {
        lhs = lhs + rhs
    }

}

// MARK: - NSRange Extension
extension NSRange {
    
    /// A range with location and length set to `0`.
    static var zero: NSRange { return NSMakeRange(0, 0) }
    
    /// Any range with a negative length is invalid.
    static var invalid: NSRange { return NSMakeRange(0, -1) }
    
    /// Returns the sum of the `location` and `length` of this range.
    /// Shorthand for `NSMaxRange(self)`.
    var max: Int { return NSMaxRange(self) }
    
    /// Range struct representatin of this range.
    var bridgedRange: Range<Int> { return location ..< max }
    
    /// Returns `true` if, and only if, `length > -1`.
    var valid: Bool { return length > -1 }
    
}

// MARK: - NSRange Addition Extension
extension NSRange {

    /// Shifts a range location and length by a specified integer tuple.
    ///
    /// - Parameters:
    ///     - lhs: range to shift.
    ///     - rhs: tuple to shift the location and length of `lhs` by.
    /// - Returns: a range with a location equal to
    /// `lhs.location + rhs.location` and length equal to
    /// `lhs.length + rhs.length`.
    static func + (lhs: NSRange, rhs: (location: Int, length: Int)) -> NSRange {
        return NSMakeRange(lhs.location + rhs.location, lhs.length + rhs.length)
    }

}

// MARK: - NSRange Shifting Extension
extension NSRange {

    subscript(_ offset: (loc: Int, length: Int)) -> NSRange {
        return NSMakeRange(location + offset.loc, length + offset.length)
    }
    
    /// Shifts the location of this range by a specified offset and adjusts
    /// its length to have the same end index, unless `true` is passed for
    /// `keepLength`.
    ///
    /// - Parameters:
    ///     - offset: to shift the location of this range by.
    ///     - keepLength: specify `true` to indicate the length of this range
    /// should remain unchanged; specfiy `false`, to indicate that the length
    /// should be adjusted to maintain the same `max` value. Default value
    /// is `false`.
    mutating func shiftLocation(by offset: Int, keepLength: Bool = false) {
        location += offset
        length = keepLength ? length : Swift.max(length - offset, 0)
    }
    
    /// Returns a copy of this range with the location shifted by a specified
    /// offset and the length adjusted to have the same end index as this range,
    /// unless `true` is passed for `keepLength`.
    ///
    /// - Parameters:
    ///     - offset: to shift the location of the range by relative to the
    /// location of this range.
    ///     - keepLength: specify `true` to indicate the length of the returned
    /// range should be equal to the range of this range; specify `false`, to
    /// indicate that the length should be adjusted to maintain the same `max`
    /// value of this range. Default value is `false`.
    /// - Returns: a copy of this range with the location shifted by a specified
    /// offset and the length adjusted to have the same end index as this range,
    /// unless `true` is passed for `keepLength`.
    func shiftingLocation(by offset: Int, keepLength: Bool = false) -> NSRange {
        return NSMakeRange(location + offset, keepLength ? length : Swift.max(length - offset, 0))
    }
    
    /// Contracts this range at both ends by a specified width. The result
    /// leaves this range with a postive, or zero, length that equal to
    /// `oldLength - (width * 2)` and a location equal to `length + width`.
    ///
    /// - Parameters:
    ///     - width: to contract this range by.
    mutating func contract(by width: Int) {
        location += width
        length = Swift.max(length - (width * 2), 0)
    }
    
    /// Expands this range at both ends by a specified width. The result
    /// leaves this range with a postive, or zero, length that equal to
    /// `oldLength + (width * 2)` and a location equal to `length - width`.
    ///
    /// - Parameters:
    ///     - width: to expand this range by.
    mutating func expand(by width: Int) {
        location -= width
        length += (width * 2)
    }
    
    /// Returns a copy of this range that is contracted at both ends by a
    /// specified width. The resultant range will have a postive, or zero,
    /// length that equal to `oldLength - (width * 2)` and a location equal
    /// to `length + width`.
    ///
    /// - Parameters:
    ///     - width: to contract this range by.
    /// - Returns: a copy of this range that has been contracted at both ends
    /// by `width`.
    func contracted(by width: Int) -> NSRange {
        return NSMakeRange(location + width, Swift.max(length - (width * 2), 0))
    }
    
    /// Returns a copy of this range that is expanded at both ends by a
    /// specified width. The resultant range will have a postive, or zero,
    /// length that equal to `oldLength + (width * 2)` and a location equal
    /// to `length - width`.
    /// - Parameters:
    ///     - width: to contract this range by.
    /// - Returns: a copy of this range that has been expanded at both ends
    /// by `width`.
    func expanded(by width: Int) -> NSRange {
        return NSMakeRange(location - width, length + (width * 2))
    }
    
}

// MARK: - Range Property Extension
extension Range where Bound == Int {
    
    /// Length of this range.
    var length: Bound { return upperBound - lowerBound }
    
    /// NSRange representation of this range.
    var bridgedRange: NSRange { return NSMakeRange(lowerBound, length) }
    
}

///
struct StringFormattingOption: BaseOptionSet {
    
    typealias This = StringFormattingOption
    typealias RawValue = Int
    
    static let escaped = This(1 << 0)
    
    static let stripOuterBraces = This(1 << 1)
    
    static let stripOuterBrackets = This(1 << 2)
    
    static let stripOuterParentheses = This(1 << 3)
    
    static let truncate = This(1 << 4)
    
    let rawValue: RawValue
    
    init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
}

// MARK: - String Path Concatenation
extension String {

    static func +/ (lhs: String, rhs: String) -> String {
        return lhs.appendingPathComponent(rhs)
    }

    static func +/ (lhs: String?, rhs: String) -> String? {
        guard let lhs = lhs else { return nil }
        return lhs.appendingPathComponent(rhs)
    }

    static func +/ (lhs: String, rhs: String?) -> String? {
        guard let rhs = rhs else { return nil }
        return lhs.appendingPathComponent(rhs)
    }

}

// MARK: - String Property Extension (NSString Bridging Properties)
extension String {
    
    /// This string casted as a `NSString`.
    /// Shorthand for `(self as NSString)`.
    fileprivate var ns: NSString { return self as NSString }
    
    /// Actual length of this string in terms of number of bytes.
    /// Shorthand for `(self as NSString).length`.
    var length: Int { return ns.length }
    
    /// Zero based range of this string.
    /// Shorthand for `NSMakeRange(0, length)`.
    var range: NSRange { return NSMakeRange(0, length) }
    
    func range(offsetBy offset: Int) -> NSRange { return NSMakeRange(offset, length - offset) }
    
    /// First letter of this string; or an empty string if this string is empty.
    var firstCharacter: String { return length > 0 ? substring(to: 1) : "" }
    
    /// Last letter of this string; or an empty string if this string is empty.
    var lastCharacter: String { return length > 0 ? substring(from: length - 1) : "" }
    
    /// Returns `true` if the first letter of this string is capitalized.
    /// An empty string will return `false`.
    var isCapitalized: Bool { return length > 0 && firstCharacter == firstCharacter.uppercased() }
    
    /// Returns `true` if this entire string is uppercased.
    /// An empty string will return `false`.
    var isUppercased: Bool { return length > 0 && self == uppercased() }
    
    /// Returns `true` if this entire string is lowercased.
    /// An empty string will return `false`.
    var isLowercased: Bool { return length > 0 && self == lowercased() }
    
    /// Last path component of this string.
    /// Shorthand for `(self as NSString).lastPathComponent`.
    var lastPathComponent: String { return ns.lastPathComponent }
    
    /// Path extension of this string.
    /// Shorthand for `(self as NSString).pathExtension`.
    var pathExtension: String { return ns.pathExtension }
    
    /// This string with the last path component removed.
    /// Shorthand for `(self as NSString).deletingLastPathComponent`.
    var deletingLastPathComponent: String { return ns.deletingLastPathComponent }
    
    /// This string with the path extension removed.
    /// Shorthand for `(self as NSString).deletingPathExtension`.
    var deletingPathExtension: String { return ns.deletingPathExtension }
    
    /// Number of lines contained in this string.
    var lineCount: Int { return components(separatedBy: .newlines).count }
    
    /// Number of lines contained in this string.
    var wordCount: Int { return components(separatedBy: .whitespacesAndNewlines).count }
    
    /// File URL instance that uses this string as the file URL path.
    /// Shorthand for `URL(fileURLWithPath: self)`.
    var fileURL: URL { return URL(fileURLWithPath: self) }
    
}

// MARK: - String Method Extension (NSString Bridging Methods)
extension String {
    
    /// Returns a new string containing the characters of the receiver up to,
    /// but not including, the one at a given index.
    ///
    /// - Parameters:
    ///     - index: An index. The value must lie within the bounds
    /// of the receiver, or be equal to the length of the receiver.
    /// Raises an rangeException if (anIndex - 1) lies beyond the end of the
    /// receiver.
    /// - Returns: A new string containing the characters of the receiver up
    /// to, but not including, the one at anIndex. If anIndex is equal to the
    /// length of the string, returns a copy of the receiver.
    func substring(to index: Int) -> String {
        return ns.substring(to: index)
    }
    
    /// Returns a new string containing the characters of the receiver up to,
    /// but not including, the one at a given index.
    ///
    /// - Parameters:
    ///     - index: An index. The value must lie within the bounds of
    /// the receiver, or be equal to the length of the receiver.
    /// Raises an rangeException if (anIndex - 1) lies beyond the end of the
    /// receiver.
    /// - Returns: A new string containing the characters of the receiver from
    /// the one at anIndex to the end. If anIndex is equal to the length of the
    /// string, returns an empty string.
    func substring(from index: Int) -> String {
        return ns.substring(from: index)
    }
    
    ///
    /// - Parameters:
    ///     - range: A range. The range must not exceed the bounds of the
    /// receiver. Raises an rangeException if `(aRange.location - 1)` or
    /// `(aRange.location + aRange.length - 1)` lies beyond the end of the
    /// receiver.
    /// - Returns: A string object containing the characters of the receiver
    /// that lie within `range`.
    func substring(with range: NSRange) -> String {
        return ns.substring(with: range)
    }
    
    ///
    /// - Parameters:
    ///     - range: A range. The range must not exceed the bounds of the
    /// receiver. Raises an rangeException if `(aRange.location - 1)` or
    /// `(aRange.location + aRange.length - 1)` lies beyond the end of the
    /// receiver.
    /// - Returns: A string object containing the characters of the receiver
    /// that lie within `range`.
    func substring(with range: Range<Int>) -> String {
        return ns.substring(with: range.bridgedRange)
    }
    
    ///
    /// - Parameters:
    ///     - range: A range. The range must not exceed the bounds of the
    /// receiver. Raises an rangeException if `(aRange.location - 1)` or
    /// `(aRange.location + aRange.length - 1)` lies beyond the end of the
    /// receiver.
    /// - Returns: A string object containing the characters of the receiver
    /// that lie within `range`.
    subscript (range: Range<Int>) -> String {
        return ns.substring(with: range.bridgedRange)
    }
    
    ///
    /// - parameter anIndex:
    /// - Returns:
    func char(at anIndex: Int) -> String {
        return substring(with: NSMakeRange(anIndex, 1))
    }
    
    ///
    /// - parameter substring:
    /// - Returns:
    func range(of substring: String) -> NSRange {
        return ns.range(of: substring)
    }
    
    ///
    /// - parameter substring:
    /// - Returns:
    func index(of substring: String) -> Int {
        return range(of: substring).location
    }
    
    ///
    /// - parameter options:
    /// - Returns:
    func format(using options: StringFormattingOption = []) -> String {
        return String(with: self, options: options)
    }
    
    /// Returns a new string made by appending to the receiver a given string.
    ///
    /// - Parameters:
    ///     - str: The path component to append to the receiver.
    /// - Returns: A new string made by appending aString to the receiver,
    /// preceded if necessary by a path separator.
    func appendingPathComponent(_ str: String) -> String {
        return ns.appendingPathComponent(str)
    }
    
    /// Returns a new string made by appending to the receiver an extension
    /// separator followed by a given extension.
    ///
    /// - Parameters:
    ///     - ext: The extension to append to the receiver.
    /// - Returns: A new string made by appending to the receiver an extension
    /// separator followed by `ext`.
    func appendingPathExtension(_ ext: String) -> String? {
        return ns.appendingPathExtension(ext)
    }
    
    /// Returns a new string in which all occurrences of a target string in a
    /// specified range of the receiver are replaced by another given string.
    ///
    /// - Parameters:
    ///     - target: to replace.
    ///     - replacement: to replace `target` with.
    ///     - options: to use when comparing `target` with the receiver.
    ///     - range: in the receiver in which to search for `target`.
    /// - Returns: A new string in which all occurrences of `target`, matched
    /// using `options`, in `searchRange` of the receiver are replaced by
    /// `replacement`.
    func replacingOccurrences(of target: String, with replacement: String, options: NSString.CompareOptions, range: NSRange) -> String {
        return ns.replacingOccurrences(of: target, with: replacement, options: options, range: range)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func matches(in string: String, options: NSRegularExpression.Options, range: NSRange? = nil) -> [NSTextCheckingResult] {
        return matches(in: string, options: (options, []), range: range)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func matches(in string: String, options: NSRegularExpression.MatchingOptions, range: NSRange? = nil) -> [NSTextCheckingResult] {
        return matches(in: string, options: ([], options), range: range)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func matches(in string: String, options: (NSRegularExpression.Options, NSRegularExpression.MatchingOptions) = ([],[]), range: NSRange? = nil) -> [NSTextCheckingResult] {
        do {
            return (try NSRegularExpression(pattern: self, options: options.0))
                .matches(in: string,
                         options: options.1,
                         range: range ?? string.range)
        } catch {
            print(error.localizedDescription)
        }
        return []
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    ///     - block:
    /// - Returns:
    func enumerateMatches(in string: String, options: NSRegularExpression.Options, range: NSRange? = nil, using block: (NSTextCheckingResult?, NSRegularExpression.MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateMatches(in: string, options: (options, []), using: block)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    ///     - block:
    /// - Returns:
    func enumerateMatches(in string: String, options: NSRegularExpression.MatchingOptions, range: NSRange? = nil, using block: (NSTextCheckingResult?, NSRegularExpression.MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void) {
        enumerateMatches(in: string, options: ([], options), using: block)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    ///     - block:
    /// - Returns:
    func enumerateMatches(in string: String, options: (NSRegularExpression.Options, NSRegularExpression.MatchingOptions) = ([],[]), range: NSRange? = nil, using block: (NSTextCheckingResult?, NSRegularExpression.MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Void) {
        do {
            (try NSRegularExpression(pattern: self, options: options.0))
                .enumerateMatches(in: string,
                                  options: options.1,
                                  range: range ?? string.range,
                                  using: block)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func doesMatch(_ string: String, options: NSRegularExpression.Options, range: NSRange? = nil) -> Bool {
        return doesMatch(string, options: (options, []), range: range)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func doesMatch(_ string: String, options: NSRegularExpression.MatchingOptions, range: NSRange? = nil) -> Bool {
        return doesMatch(string, options: ([], options), range: range)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func doesMatch(_ string: String, options: (NSRegularExpression.Options, NSRegularExpression.MatchingOptions) = ([],[]), range: NSRange? = nil) -> Bool {
        return firstMatch(in: string, options: options, range: range) != nil
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func firstMatch(in string: String, options: NSRegularExpression.Options, range: NSRange? = nil) -> NSTextCheckingResult? {
        return firstMatch(in: string, options: (options, []), range: range)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions, range: NSRange? = nil) -> NSTextCheckingResult? {
        return firstMatch(in: string, options: ([], options), range: range)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - string:
    ///     - options:
    ///     - range:
    /// - Returns:
    func firstMatch(in string: String, options: (NSRegularExpression.Options, NSRegularExpression.MatchingOptions) = ([],[]), range: NSRange? = nil) -> NSTextCheckingResult? {
        do {
            return (try NSRegularExpression(pattern: self, options: options.0))
                .firstMatch(in: string,
                            options: options.1,
                            range: range ?? string.range)
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    ///
    ///
    ///
    func split(by pattern: String) -> [String] {
        guard let re = try? NSRegularExpression(pattern: pattern, options: [])
            else { return [] }
        let nsString = self as NSString // needed for range compatibility
        let stop = "<SomeStringThatYouDoNotExpectToOccurInSelf>"
        let modifiedString = re.stringByReplacingMatches(
            in: self,
            options: [],
            range: NSRange(location: 0, length: nsString.length),
            withTemplate: stop)
        return modifiedString.components(separatedBy: stop)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - attributes:
    /// - Returns:
    func size(withAttributes attributes: [NSAttributedString.Key: Any]) -> CGSize {
        return ns.size(withAttributes: attributes)
    }
    
    ///
    ///
    /// - Parameters:
    ///     - attributes:
    /// - Returns:
    func width(withAttributes attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        return size(withAttributes: attributes).width
    }
    
    ///
    ///
    /// - Parameters:
    ///     - attributes:
    /// - Returns:
    func height(withAttributes attributes: [NSAttributedString.Key: Any]) -> CGFloat {
        return size(withAttributes: attributes).height
    }
    
}

extension String {
    
    ///
    init(with arg: CVarArg, options: StringFormattingOption = []) {
        var text = String(format: "%@", arg)
        switch options {
            
        case _ where options.contains(.stripOuterBraces):
            break
            
        default:
            break
            
        }
        if options.contains(.escaped) {
            text = text.ns.replacingOccurrences(of: "\\r", with: "\\\\r", options: .regularExpression, range: text.range)
            text = text.ns.replacingOccurrences(of: "\\n", with: "\\\\n", options: .regularExpression, range: text.range)
            text = text.ns.replacingOccurrences(of: "\\t", with: "\\\\t", options: .regularExpression, range: text.range)
            text = text.ns.replacingOccurrences(of: "\\s", with: "\\\\s", options: .regularExpression, range: text.range)
        }
        self = text
    }
    
}

// MARK: - URL Path Concatenation
extension URL {
    
    static func +/ (lhs: URL, rhs: String) -> URL {
        return lhs.appendingPathComponent(rhs)
    }
    
    static func +/ (lhs: URL, rhs: String?) -> URL? {
        guard let rhs = rhs else { return nil }
        return lhs.appendingPathComponent(rhs)
    }
    
}

func +/ (lhs: URL?, rhs: String) -> URL? {
    guard let lhs = lhs else { return nil }
    return lhs.appendingPathComponent(rhs)
}

// MARK: - URL Property Extension
extension URL {
    
    ///
    var pathComponentsResolvingSymlinksInPath: [String] {
        return resolvingSymlinksInPath().pathComponents
    }
    
    @available(OSX 10.11, iOS 9.0, *)
    func relativeTo(baseURL: URL) -> URL {
        return URL(fileURLWithPath: resolvingSymlinksInPath().path, relativeTo: baseURL)
    }
    
}
