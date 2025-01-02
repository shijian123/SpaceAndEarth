//
//  SolarSystemImmersiveView.swift
//  SpaceAndEarth
//
//  Created by 达达 on 2024/11/26.
//

import SwiftUI
import RealityKit
import Combine

struct SolarSystemImmersiveView: View {
    
    var body: some View {
        
        RealityView { content in
            await createSolarSystem(content: content)
        }
    }
}

extension SolarSystemImmersiveView {
    
    func createSolarSystem(content:any RealityViewContentProtocol) async {
        if let solarSystem = try? await Entity(named: "Solar_System_animation") {
            solarSystem.position = SIMD3<Float>(x: 0, y: -2, z: -1)
            solarSystem.scale = SIMD3<Float>(0.015,0.015,0.015)
            if let animation = solarSystem.availableAnimations.first {
                solarSystem.playAnimation(animation.repeat())
            }
            content.add(solarSystem)
        }
    }
}
