//
//  Source.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 12/3/23.
//

import Foundation

protocol Source: Codable, Hashable {
    var id: UUID { get }
    var name: String { get }
    var more: String? { get }
    var grossValue: Double { get }
    var recurrence: Recurrence? { get }
}
