//
//  PortForward.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import Foundation
import SwiftUI

struct PortForwardItem: View {
    @ObservedObject var portForward: KubePortForwardResource
    
    @State private var showEditSheet = false
    
    var deleteAction: (() -> Void)
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(portForward.resourceName)
                        .bold()
                        .font(.title2)
                    
                    if portForward.status == .error {
                        Text(portForward.errorDescription ?? "Error")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.leading)
                    }
                }
                Text(portForward.resourceType.description)
                    .font(.subheadline)
            }.padding()
            Spacer()
            Group {
                Text(prettyPorts)
                Button {
                    showEditSheet.toggle()
                } label: {
                    Label("Edit", systemImage: "gear")
                        .labelStyle(.iconOnly)
                }.buttonStyle(.borderless).disabled(portForward.status == .running)
                Button {
                    portForward.startStop()
                } label: {
                    Label("Start/Stop", systemImage: buttonIcon)
                        .labelStyle(.iconOnly)
                }.buttonStyle(.borderedProminent)
            }.padding()
        }.sheet(isPresented: $showEditSheet) {
            EditPortForward(portForwardResource: portForward) {
                deleteAction()
            }
        }
    }
    
    var prettyPorts: String {
        if (portForward.forwardedPorts.isEmpty) {
            return ""
        }
        
        let firstPortForward = portForward.forwardedPorts.first!
        var result = "\(firstPortForward.localPort ?? 0):\(firstPortForward.remotePort ?? 0)"
        
        if (portForward.forwardedPorts.count > 1) {
            result += ", ..."
        }
        
        return result
    }
    
    var buttonIcon: String {
        switch portForward.status {
        case .running:
            return "stop.fill"
        case .stopped:
            return "play.fill"
        case .idle:
            return "play.fill"
        case.error:
            return "exclamationmark.triangle.fill"
        }
    }
}

#Preview() {
    @Previewable @StateObject var portForward = KubePortForwardResource(resourceName: "test-service", resourceType: .service, namespace: "test-1", forwardedPorts: [PortMapping(localPort: 7701, remotePort: 80)])
    PortForwardItem(portForward: portForward) { }
}
