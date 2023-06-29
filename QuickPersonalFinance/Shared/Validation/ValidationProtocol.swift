//
//  Validation.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 21/3/23.
//

import Foundation

protocol Validation {
    var value: String { get set }
    var isValid: Bool { get }
}
