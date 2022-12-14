//
//  File.swift
//  SuperView
//
//  Created by Joe Manto on 9/19/21.
//

import Foundation
import Cocoa

enum LogType {
    case info, err, warn
}

class Logging {
    
    static let shared = Logging()
    
    func saveLogs() {
        guard let urlString = Settings.shared.string(forKey: Setting.logFileUrl, log: false),
              let url = URL(string: urlString) else {
            Logging.shared.log(msg: "Couldn't get logs url", comp: "[Logging]", type: .err)
            return
        }
    
        let savePanel = NSSavePanel()
        savePanel.level = .modalPanel
        savePanel.begin { (result) in
            guard result == NSApplication.ModalResponse.OK,
                  let dstUrl = savePanel.url else {
                return
            }
            
            do {
                try FileManager().copyItem(at: url, to: dstUrl)
            }
            catch {
                Logging.shared.log(msg: "Couldn't copy logs to path \(dstUrl.absoluteString)", comp: "[Logging]", type: .err)
            }
        }
    }
    
    func resetLogs() {
        self.removeLogFile()
        try? self.createNewLogFile()?.close()
    }
    
    private func removeLogFile() {
        guard let logUrlString = Settings.shared.string(forKey: Setting.logFileUrl, log: false),
              let url = URL(string: logUrlString) else {
            return
        }
        
        try? FileManager().removeItem(atPath: url.path)
    }
    
    private func createNewLogFile() -> FileHandle? {
        self.removeLogFile()
        let temporaryDirectoryURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let temporaryFilename = ProcessInfo().globallyUniqueString
        let temporaryFileURL = temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
        
        FileManager().createFile(atPath: temporaryFileURL.path, contents: nil, attributes: [:])
        
        Settings.shared.setValue(temporaryFileURL.absoluteString, forKey: Setting.logFileUrl, log: false)
       
        return try? FileHandle(forUpdating: temporaryFileURL)
    }
    
    private func openLogFileForWriting() -> FileHandle? {
        if let absUrl = Settings.shared.string(forKey: Setting.logFileUrl, log: false),
            let url = URL(string: absUrl),
            let fileHandler = try? FileHandle(forUpdating: url) {
            return fileHandler
        }
        else {
            return createNewLogFile()
        }
    }
    
    func log(marker: String) {
        let msg = "-------------------\(marker)-------------------"
        self.log(msg: msg)
    }
    
    func log(msg: String, comp: String = "[Unk]", type: LogType = .info) {
        guard let fileHandler = openLogFileForWriting() else {
            return
        }
        guard (try? fileHandler.seekToEnd()) != nil else {
            try? fileHandler.close()
            return
        }
        
        
        var component = comp
        if comp.count < 15 {
            component.append(String.init(repeating: " ", count: 15 - comp.count))
        }
        
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = format.string(from: Date())
        
        var logType: String = ""
        switch type {
            case .err:
                logType = "[E]"
            case .warn:
                logType = "[W]"
            case .info:
                logType = "[I]"
        }
        
        let logMessage = "\(date)+\(logType)+\(component) \(msg)\n"
        onDebug {
            print(logMessage)
        }
        fileHandler.write(logMessage.data(using: .utf8) ?? Data())
        
        try? fileHandler.close()
    }
}
