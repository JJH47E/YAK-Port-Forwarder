//
//  StringExtensions.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 11/07/2025.
//

import Foundation

extension String? {
    func unwrap() -> String {
        return self ?? "nil"
    }
}
