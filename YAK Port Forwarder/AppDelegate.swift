//
//  AppDelegate.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var viewModel: KubeViewModel?

    func applicationWillTerminate(_ notification: Notification) {
        guard let viewModel else { return }

        let running = viewModel.portForwards.filter { $0.status == .running }
        guard !running.isEmpty else { return }

        // Send SIGTERM to all processes simultaneously, then wait with a shared 2-second deadline.
        let group = DispatchGroup()
        for resource in running {
            group.enter()
            DispatchQueue.global().async {
                resource.stopAndWait(timeout: 2)
                group.leave()
            }
        }
        group.wait()
    }
}
