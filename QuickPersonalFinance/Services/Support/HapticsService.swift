//
//  HapticsService.swift
//  QuickPersonalFinance
//
//  Created by Armando Brito on 6/7/23.
//

import UIKit

class HapticsService {
    func impactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    func selectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    func notificationFeedback(_ notificationType: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(notificationType)
    }
}
