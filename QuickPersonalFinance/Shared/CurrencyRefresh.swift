//
//  CurrencyRefresh.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 3/7/23.
//

import Foundation

enum CurrencyRefresh {
    case never
    case always
    case after(TimeInterval)
}
