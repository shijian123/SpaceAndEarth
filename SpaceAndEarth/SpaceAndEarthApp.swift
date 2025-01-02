//
//  SpaceAndEarthApp.swift
//  SpaceAndEarth
//
//  Created by 达达 on 2024/11/26.
//

import SwiftUI

@main
struct Day14App: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace_Full") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .mixed)

        ImmersiveSpace(id: "ImmersiveSpace_SolarSystem") {
            SolarSystemImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
        
        ImmersiveSpace(id: "EarthImmersiveView") {
            EarthImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
    
    init() {
        EarthChaserComponent.registerComponent()
        EarthChaserSystem.registerSystem()
    }
}
 
