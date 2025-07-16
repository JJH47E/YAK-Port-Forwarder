//
//  UrlHelper.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 16/07/2025.
//

import Foundation

class UrlHelper {
    static func isValidUrl(_ urlString: String) -> Bool {
        if urlString.isEmpty {
            return false
        }
        
        let parsedUrl = URL(string: urlString)
        return parsedUrl != nil
    }
}
