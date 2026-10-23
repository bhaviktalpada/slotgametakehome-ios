//
//  ThemeColor.swift
//  slotgametakehome
//
//  Created by Developer on 22/10/26.
//

import UIKit

enum ThemeColor {

    // Cabinet background wine red
    static func arcadeBackground(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 0.35, green: 0.05, blue: 0.05, alpha: alpha)
    }

    // Core gold accent used for title, buttons, borders, and paylines
    static func gold(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: alpha)
    }

    // Warm orange glow for drop shadows
    static func orangeGlow(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 1.0, green: 0.60, blue: 0.0, alpha: alpha)
    }

    // Reel column dark background
    static func reelBackground(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 0.08, green: 0.10, blue: 0.15, alpha: alpha)
    }

    // Reel column slate blue border
    static func reelBorder(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 0.25, green: 0.30, blue: 0.42, alpha: alpha)
    }

    // Dark background for segmented controls
    static func controlBackground(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 0.08, green: 0.10, blue: 0.16, alpha: alpha)
    }

    // Dev HUD background
    static func devBackground(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 0.06, green: 0.08, blue: 0.14, alpha: alpha)
    }

    // Dev HUD border
    static func devBorder(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 0.30, green: 0.45, blue: 0.65, alpha: alpha)
    }

    // Dev mode active badge green
    static func devBadgeGreen(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: alpha)
    }

    // Prod mode badge gray
    static func prodBadgeGray(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(white: 0.28, alpha: alpha)
    }

    // Test result button background
    static func testButtonBackground(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(white: 0.22, alpha: alpha)
    }

    // Winning outcome text green
    static func winGreen(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 0.20, green: 0.95, blue: 0.30, alpha: alpha)
    }

    // Loss and insufficient balance red
    static func lossRed(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(red: 1.0, green: 0.35, blue: 0.35, alpha: alpha)
    }

    // Session statistics text gray
    static func statsText(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(white: 0.82, alpha: alpha)
    }

    // Disabled button text
    static func disabledText(alpha: CGFloat = 1.0) -> UIColor {
        UIColor(white: 0.30, alpha: alpha)
    }
}
