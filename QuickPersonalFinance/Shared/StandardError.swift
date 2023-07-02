//
//  StandardError.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 1/7/23.
//

import Foundation

enum StandardError: LocalizedError {
    case unknown

    var errorDescription: String? {
        "error.unknown".localized
    }
}
