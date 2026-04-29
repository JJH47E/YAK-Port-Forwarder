//
//  PreferencesView.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/04/2026.
//

import SwiftUI

struct PreferencesView: View {
    @AppStorage("customKubectlPath") private var customKubectlPath: String = ""

    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("kubectl binary path", text: $customKubectlPath)
                        .textFieldStyle(.roundedBorder)
                    Button("Browse…") {
                        browseForKubectl()
                    }
                    Button("Clear") {
                        UserDefaults.standard.removeObject(forKey: "customKubectlPath")
                        customKubectlPath = ""
                    }
                    .disabled(customKubectlPath.isEmpty)
                }
                Text("Leave blank to use kubectl found on your shell PATH.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("kubectl Binary Path")
            }
        }
        .formStyle(.grouped)
        .padding()
        .frame(minWidth: 480)
    }

    private func browseForKubectl() {
        let panel = NSOpenPanel()
        panel.title = "Select kubectl Binary"
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.showsHiddenFiles = true

        if panel.runModal() == .OK, let url = panel.url {
            customKubectlPath = url.path
        }
    }
}

#Preview {
    PreferencesView()
}
