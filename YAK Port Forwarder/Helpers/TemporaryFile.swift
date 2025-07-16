//
//  TemporaryFile.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 16/07/2025.
//

import Foundation

class TemporaryFile {
    private let url: URL
    
    init(filename: String) {
        let directory = NSTemporaryDirectory()
        self.url = NSURL.fileURL(withPathComponents: [directory, filename])!
    }
    
    convenience init() {
        self.init(filename: NSUUID().uuidString)
    }
    
    func write(_ data: Data) throws {
        try data.write(to: self.url)
    }
}
