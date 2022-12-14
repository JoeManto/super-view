//
//  LocalWindowViewController.swift
//  zapp
//
//  Created by Joe Manto on 9/7/21.
//

import Foundation
import Cocoa
import WebKit

class LocalViewController: WebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectLocalFile()
    }
    
    func selectLocalFile() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose file"
        dialog.showsResizeIndicator = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false

        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            guard dialog.urls.count > 0,
                  let firstFileUrl = dialog.urls.first else {
                Logging.shared.log(msg: "No File Selected", comp: "[LocalViewController]")
                return
            }
            // Do whatever you need with every selected file
            // in this case, print on the terminal every path
            webView.loadFileURL(firstFileUrl, allowingReadAccessTo: firstFileUrl)
            addressBar.addressField.stringValue = firstFileUrl.absoluteString
            Logging.shared.log(msg: "Opening Selected File", comp: "[LocalViewController]")
        } else {
            Logging.shared.log(msg: "Canceled File Selection", comp: "[LocalViewController]")
            return
        }
    }
}
