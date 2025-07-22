//
//  KubectlExitReasonHelper.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 22/07/2025.
//

import Foundation

class KubectlExitReasonHelper {
    static func getExitReason(from exitCode: Int32) -> String {
        let localExitCode = exitCode % 128
        
        switch localExitCode {
        case 1:
            return "Unspecified error, does the resource exist?"
        case 2:// SIGINT
            return "Terminated by Interrupt (SIGINT - \(exitCode)"
        case 9:// SIGKILL
            return "Terminated by Kill (SIGKILL - \(exitCode)"
        case 15:// SIGTERM
            return "Terminated gracefully (SIGTERM - \(exitCode)"
        case 126:
            return "Permission denied"
        case 127:
            return "Command not found"
        default:
            return "An unknown error occured. Kubectl exit code: \(exitCode)"
        }
    }
}
