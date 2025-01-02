//
//  ContentView.swift
//  SpaceAndEarth
//
//  Created by 达达 on 2024/11/26.
//

import SwiftUI
import RealityKit

struct ContentView: View {

    @State var showImmersiveSpace_Full = false
    @State var showImmersiveSpace_SolarSystem = false

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    
    //进入
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack {
                Toggle("进入太空", isOn: $showImmersiveSpace_Full)
                    .toggleStyle(.button)
                    .disabled(fullIsValid)
                    .padding(.top, 50)
                
                Toggle("进入太阳系", isOn: $showImmersiveSpace_SolarSystem)
                    .toggleStyle(.button)
                    .disabled(solarSystem)
                    .padding(.top, 50)
            }
        }
        .onChange(of: showImmersiveSpace_Full) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace_Full")
                    dismiss()
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
        .onChange(of: showImmersiveSpace_SolarSystem) { _, newValue in
            Task {
                if newValue {
                    await openImmersiveSpace(id: "ImmersiveSpace_SolarSystem")
                    dismiss()
                } else {
                    await dismissImmersiveSpace()
                }
            }
        }
    }

    var fullIsValid: Bool {
        return showImmersiveSpace_SolarSystem
    }
    
    var solarSystem: Bool {
        return showImmersiveSpace_Full
    }
}

#Preview {
    ContentView()
}
