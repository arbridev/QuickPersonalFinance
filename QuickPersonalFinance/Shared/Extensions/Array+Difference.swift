//
//  Array+Difference.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 18/4/23.
//

import Foundation

extension Array where Element: Hashable {
    /// Elements of this array that are not present in `other`.
    func subtracting(_ other: [Element]) -> [Element] {
        let otherSet = Set(other)
        return filter { !otherSet.contains($0) }
    }
}
