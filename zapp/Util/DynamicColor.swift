//
//  DynamicColor.swift
//  SuperWindow
//
//  Created by Joe Manto on 10/9/21.
//

import Foundation
import AppKit

extension NSColor {
    
    static let backgroundPrimary = NSColor(light: .white, dark: .black)
    static let textColorPrimary = NSColor(light: .black, dark: .white)
    static let secondaryTextColor = NSColor.lightGray
    static let addressBarBackground = NSColor.lightGray
    
    convenience init(light: NSColor, dark: NSColor) {
        self.init(name: nil, dynamicProvider: { appearance in
            if UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark" {
                return dark
            }
            return light
        })
    }
}
