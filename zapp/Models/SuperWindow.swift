//
//  SuperWindow.swift
//  zapp
//
//  Created by Joe Manto on 9/4/21.
//

import Foundation
import Cocoa

enum WindowType {
    case Web, Local, Info, Bug, Feature, FromCopy, Purchases
}

enum WindowLocation {
    case TopRight, TopLeft, BottomRight, BottomLeft, Unknown
}

class SuperWindow: NSWindow {
    
    let type: WindowType
    var location: WindowLocation
    
    required init(_ type: WindowType = .Web) {
        self.type = type
        self.location = .Unknown
        var style = StyleMask()

        style.formUnion(.titled)
        style.formUnion(.closable)
        style.formUnion(.miniaturizable)
        style.formUnion(.resizable)
        style.subtract(.fullScreen)

        super.init(contentRect: DEFAULT_WINDOW_FRAME, styleMask: style, backing: .buffered, defer: false)
        self.isReleasedWhenClosed = true
        self.standardWindowButton(.zoomButton)?.isEnabled = false
        
        self.level = Level(rawValue: Int(CGWindowLevelForKey(.floatingWindow)))
        self.collectionBehavior = CollectionBehavior(rawValue: (
            CollectionBehavior.fullScreenAuxiliary.rawValue |
            CollectionBehavior.fullScreenDisallowsTiling.rawValue
        ))
        
        self.miniwindowImage = NSImage(named: "AppIcon")
    }
}

