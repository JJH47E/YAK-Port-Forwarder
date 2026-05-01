//
//  KubectlExitReasonHelper.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 22/07/2025.
//

import Foundation

class KubectlExitReasonHelper {
    static func getExitReason(from exitCode: Int32, stderr: String? = nil) -> String {
        let localExitCode = exitCode % 128

        let codeMessage: String
        switch localExitCode {
        case 1:
            codeMessage = "Unspecified error, does the resource exist?"
        case 2:
            codeMessage = "Terminated by Interrupt (SIGINT - \(exitCode))"
        case 9:
            codeMessage = "Terminated by Kill (SIGKILL - \(exitCode))"
        case 15:
            codeMessage = "Terminated gracefully (SIGTERM - \(exitCode))"
        case 126:
            codeMessage = "Permission denied"
        case 127:
            codeMessage = "Command not found"
        default:
            codeMessage = "An unknown error occurred. Kubectl exit code: \(exitCode)"
        }

        if let stderr = stderr, !stderr.isEmpty {
            return "\(codeMessage): \(stderr)"
        }
        return codeMessage
    }
}
