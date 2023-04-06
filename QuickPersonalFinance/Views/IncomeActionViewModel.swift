//
//  IncomeActionViewModel.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 14/3/23.
//

import Foundation

extension IncomeActionView {

    @MainActor class ViewModel: ObservableObject {
        @Published var grossValueText: String = "" {
            didSet {
                let preemptiveValidation = DoubleValidation(value: grossValueText)
                if !preemptiveValidation.isValid {
                    grossValueText = oldValue
                }
            }
        }
        @Published var grossValueErrorMessage: String?

        func submit() {
            let grossValueValidation = DoubleValidation(value: grossValueText)
            if grossValueText.isEmpty || !grossValueValidation.isValid {
                grossValueErrorMessage = "A gross income value is required"
            } else {
                grossValueErrorMessage = nil
            }
        }
    }

}

struct DoubleValidation: Validation {
    var value: String
    var isValid: Bool {
        !(value.count > 0 && Double(value) == nil)
    }
}
