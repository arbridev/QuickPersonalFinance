//
//  Source.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 12/3/23.
//

import Foundation

protocol Source: Codable, Hashable {
    var name: String { get }
    var more: String? { get }
    var netValue: Double { get }
    var recurrence: Recurrence? { get }
}
