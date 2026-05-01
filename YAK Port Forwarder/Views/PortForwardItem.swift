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
    var availableContexts: [String]

    @State private var showEditSheet = false
    @State private var showErrorDetail = false

    var deleteAction: (() -> Void)

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Text(portForward.resourceName)
                        .bold()
                        .font(.title2)

                    if portForward.status == .error {
                        Text("Process error")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .padding(.leading)
                        Button {
                            showErrorDetail.toggle()
                        } label: {
                            Label("Details", systemImage: "info.circle")
                                .labelStyle(.iconOnly)
                        }
                        .buttonStyle(.borderless)
                        .foregroundStyle(.red)
                        .popover(isPresented: $showErrorDetail) {
                            ScrollView {
                                Text(portForward.errorDescription ?? "Unknown error")
                                    .textSelection(.enabled)
                                    .padding()
                            }
                            .frame(width: 320)
                        }
                    }
                }
                Text("Namespace: \(portForward.namespace)")
                Text(portForward.resourceType.description)
                    .font(.subheadline)
                Text("Context: \(portForward.context ?? "Default context")")
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
            EditPortForward(portForwardResource: portForward, availableContexts: availableContexts) {
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
    PortForwardItem(portForward: portForward, availableContexts: ["dev-cluster", "staging-cluster"]) { }
}
