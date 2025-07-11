//
//  ContentView.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 29/06/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: KubeViewModel
    
    var body: some View {
        Splash(viewModel: viewModel)
    }
}

#Preview {
    @Previewable @StateObject var viewModel = PreviewKubeDataProvider()
    ContentView(viewModel: viewModel)
}
