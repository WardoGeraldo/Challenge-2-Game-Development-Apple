//
//  HapticManager.swift
//  PaoApp
//
//  Created by Saujana Shafi on 05/05/26.
//

import Foundation
import UIKit

// TODO: Decide wether simple haptics is enough (use UIImpact) or will need complex haptics (CoreHaptic)
final class HapticManager {
    static let shared = HapticManager()

    private init() {}

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }

    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
