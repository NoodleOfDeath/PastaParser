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

import Foundation

extension ComparisonResult {

    ///
    public static var lessThan: ComparisonResult { return .orderedAscending }

    ///
    public static var equalTo: ComparisonResult { return .orderedSame }

    ///
    public static var greaterThan: ComparisonResult { return .orderedDescending }

    ///
    public var inverse: ComparisonResult {
        switch self {
        case .lessThan: return .greaterThan
        case .greaterThan: return .lessThan
        default: return .equalTo
        }
    }

    ///
    public init(_ stringValue: String) {
        switch stringValue {
        case "<": self = .lessThan
        case ">": self = .greaterThan
        default: self = .equalTo
        }
    }

}

// MARK: - Codable Extension
extension ComparisonResult: Codable {}

// MARK: - CustomStringConvertible Extension
extension ComparisonResult: CustomStringConvertible {

    public var description: String {
        switch self {
        case .lessThan: return "<"
        case .greaterThan: return ">"
        default: return "="
        }
    }

}

///
public protocol ComparisonGraphNode {

    var id: String { get }

}

///
public class ComparisonGraph<T: ComparisonGraphNode> {

    ///
    public var nodes = [T]()

    ///
    public var weights = [String: Int]()

    ///
    public var relations = [String: [String: ComparisonResult]]()

    ///
    var equalRelations = [(String, String)]()

    ///
    ///
    /// - Parameters:
    ///     - nodes:
    public init(nodes: [T] = []) {
        self.nodes = nodes
    }

    ///
    ///
    /// - Parameters:
    ///     - a:
    ///     - b:
    ///     - relation:
    public func connect(_ a: String, _ b: String, _ relation: ComparisonResult) {
        oneWayConnect(a, b, relation)
        if relation == .equalTo { return }
        oneWayConnect(b, a, relation.inverse)
    }

    ///
    ///
    /// - Parameters:
    ///     - a:
    ///     - b:
    ///     - relation:
    public func connect(_ a: String, _ b: String, _ relation: String) {
        switch relation {
        case "<": connect(a, b, .lessThan)
        case ">": connect(a, b, .greaterThan)
        default: connect(a, b, .equalTo)
        }
    }

    /// Sets the weight for a node with the specified id.
    ///
    /// - Parameters:
    ///     - weight: to set for a node.
    ///     - id: of the node to set the weight for.
    public func set(weight: Int, for id: String) {
        weights[id] = weight
    }

    ///
    ///
    /// - Parameters:
    ///     - a:
    ///     - b:
    ///     - excluding:
    /// - Returns:
    public func compare(_ a: String, _ b: String, _ excluding: [String] = []) -> ComparisonResult {
        if let a = weights[a] {
            if  let b = weights[b] {
                return (a < b ? .lessThan : a > b ? .greaterThan : .equalTo)
            }
            if a == .min { return .lessThan }
        }
        if let relations = self.relations[a] {
            if let value = relations[b] { return value }
            for (id, relation) in relations {
                guard !excluding.contains(id), relation != .greaterThan else { continue }
                return compare(id, b, excluding + [a, b, id])
            }
        }
        return .equalTo
    }

    ///
    ///
    /// - Parameters:
    ///     - a:
    ///     - b:
    /// - Returns:
    public func compare(_ a: T, _ b: T) -> ComparisonResult {
        return compare(a.id, b.id)
    }

    /// Returns the nodes of this graph in sorted order based on relation and
    /// weight constraints.
    ///
    /// - Parameters:
    ///     - reversed: `true` if the nodes should be sorted in
    ///     `.orderedDescending` order (i.e. largest to smallest); default
    ///     value is `false`.
    /// - Returns: the nodes of this graph in sorted order based on relation and
    /// weight constraints.
    func sorted(reversed: Bool = false) -> [T] {
        return nodes.sorted {
            if reversed { return self.compare($0.id, $1.id) != .lessThan }
            return self.compare($0.id, $1.id) == .lessThan
        }
    }

    /// Connects all nodes that are equal to each other and any respective
    /// relations they should share.
    func deriveEqualRelations() {
        for (a, b) in equalRelations {
            if let relations = self.relations[b] {
                for (id, relation) in relations.filter({ $0.1 != .equalTo }) {
                    connect(a, id, relation)
                }
            }
        }
    }

    ///
    ///
    /// - Parameters:
    ///     - a:
    ///     - b:
    ///     - relation:
    fileprivate func oneWayConnect(_ a: String, _ b: String, _ relation: ComparisonResult) {
        var relations = self.relations[a] ?? [:]
        relations[b] = relation
        self.relations[a] = relations
        if relation == .equalTo {
            equalRelations.append((a, b))
            if let weight = weights[b] {
                set(weight: weight, for: a)
            }
        }
    }

}

// MARK: - CustomStringConvertible Extension
extension ComparisonGraph: CustomStringConvertible {

   public var description: String {
        var strings = [String]()
        for (id, map) in relations {
            let weight = weights[id]
            strings.append("\(id)(\(weight ?? 0)) -> \(map.sorted { $0.1 == .lessThan && $0.1 != $1.1 })")
        }
        return strings.joined(separator: "\n")
    }

}
