//
//  AppStorageWrapper.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 16/07/2025.
//

import Foundation
import SwiftUI

class AppStorageWrapper {
    @AppStorage("kubectlBinPath") var kubectlBinUrl: URL?
}
