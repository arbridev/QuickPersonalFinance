//
//  Income.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 10/3/23.
//

import Foundation

struct Income: Codable, Hashable {
    let netValue: Double
    let recurrence: Recurrence?
}
