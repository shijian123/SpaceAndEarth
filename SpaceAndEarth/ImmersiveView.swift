//
//  ImmersiveView.swift
//  SpaceAndEarth
//
//  Created by 达达 on 2024/11/26.
//

import SwiftUI
import RealityKit
import Combine

struct ImmersiveView: View {
    
    @State private var audioController: AudioPlaybackController?

    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @State var VRContent: (any RealityViewContentProtocol)?
    
    var body: some View {
        
        RealityView { content in
            VRContent = content
            await createScene(content: content)
            await createEarth(content: content)
            await spaceStation_1(content: content)
            await spaceMan_1(content: content)
            await spaceMan_2(content: content)
            await spaceMan_3(content: content)
            
        }
        .gesture(TapGesture()
            .targetedToAnyEntity()
            .onEnded { event in
                handleTap()
            }
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                Task {
                    await spaceStation_2(content: VRContent!)
                    await spaceStation_3(content: VRContent!)
                    await starship(content: VRContent!)
                }
            }
        }
        .onDisappear() {
            // 停止音频播放
            audioController?.stop()
        }
    }
}


extension ImmersiveView {
    
    //创建场景
    func createScene(content:any RealityViewContentProtocol) async {
        if let spaceStation = try? await Entity(named: "Milky_Way_Skybox_HDRI_panorama") {
            spaceStation.scale *= .init(x: -100, y: 100, z: 150)
            spaceStation.transform.translation += SIMD3<Float>(0.0, 0.0, 0.0)
            
            // 加载并播放音频资源
            if let audioResource = try? AudioFileResource.load(named: "No Time For Caution") {
                let audioEntity = Entity()
                let audioController = audioEntity.prepareAudio(audioResource)
                audioController.play()
                audioController.completionHandler = {
                    audioController.play()
                }
                spaceStation.addChild(audioEntity)
                self.audioController = audioController
            }
            
            content.add(spaceStation)
        }
    }
    
    //创建地球
    func createEarth(content:any RealityViewContentProtocol) async {
        if let earth = try? await Entity(named: "Earth") {
            earth.position = SIMD3<Float>(0, 1.4, 0)
            earth.scale = SIMD3<Float>(2.5, 2.5, 2.5)
            // 创建月球
            let moon = try! await Entity(named: "earth_moon")
            moon.position = SIMD3<Float>(x: 1, y: 1.4, z: 0)
            moon.scale = SIMD3<Float>(0.0005, 0.0005, 0.0005)
            
            // 创建一个父实体
            let earthMoonSystem = Entity()
            earthMoonSystem.addChild(earth)
            earthMoonSystem.addChild(moon)
            earthMoonSystem.position = SIMD3<Float>(x: -0.25, y: 0, z: -0.5)
            //环境光
            let environment = try! await EnvironmentResource(named: "Sunlight")
            earthMoonSystem.components[ImageBasedLightComponent.self] = .init(source: .single(environment),intensityExponent: 12)
            earthMoonSystem.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: earthMoonSystem)

            // 订阅更新事件，使父实体旋转
            let _ = content.subscribe(to: SceneEvents.Update.self) { event in
                let rotation = simd_quatf(angle: 0.0005, axis: SIMD3<Float>(0,1,0))
                earthMoonSystem.transform.rotation *= rotation
                let rotation1 = simd_quatf(angle: 0.001, axis: SIMD3<Float>(0,1,0))
                let rotation2 = simd_quatf(angle: 0.002, axis: SIMD3<Float>(0,1,0))
                earth.transform.rotation *= rotation1
                moon.transform.rotation *= rotation2
            }
            
            // 将父实体添加到场景中
            content.add(earthMoonSystem)
            
            // 添加手势
            addGesture(to: earth)
            
        }
    }
    
    func createMoon(content:any RealityViewContentProtocol) async {
        if let moon = try? await Entity(named: "earth_moon") {
            moon.position = SIMD3<Float>(x: 3, y: 1.4, z: -0.5)
            moon.scale = SIMD3<Float>(2.0,2.0,2.0)
            let _ = content.subscribe(to: SceneEvents.Update.self) { event in
                let rotation = simd_quatf(angle: 0.01, axis: SIMD3<Float>(0,1,0))
                moon.transform.rotation *= rotation
            }
            content.add(moon)
        }
    }
    
    //空间站
    func spaceStation_1(content:any RealityViewContentProtocol) async {
        if let spaceStation = try? await Entity(named: "Space_Station_1") {
            spaceStation.position = SIMD3<Float>(x: 15, y: 5, z: -40.0)
            spaceStation.scale = SIMD3<Float>(0.05,0.05,0.05)
            if let animation = spaceStation.availableAnimations.first {
                spaceStation.playAnimation(animation.repeat())
            }
            
            //环境光
            let environment = try! await EnvironmentResource(named: "Sunlight")
            spaceStation.components[ImageBasedLightComponent.self] = .init(source: .single(environment),intensityExponent: 12)
            spaceStation.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: spaceStation)
            
            content.add(spaceStation)
        }
    }
    
    func spaceStation_2(content:any RealityViewContentProtocol) async {
        if let spaceStation = try? await Entity(named: "Space_Station_2") {
            spaceStation.position = SIMD3<Float>(x: 75, y: -20, z: 0.0)
            spaceStation.scale = SIMD3<Float>(0.03,0.03,0.03)
            content.subscribe(to: SceneEvents.Update.self) { event in
                let rotation = simd_quatf(angle: 0.005, axis: SIMD3<Float>(0,1,0))
                spaceStation.transform.rotation *= rotation
            }
            
            //环境光
            let environment = try! await EnvironmentResource(named: "Sunlight")
            spaceStation.components[ImageBasedLightComponent.self] = .init(source: .single(environment),intensityExponent: 12)
            spaceStation.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: spaceStation)
            
            content.add(spaceStation)
        }
    }
    
    func spaceStation_3(content:any RealityViewContentProtocol) async {
        if let spaceStation = try? await Entity(named: "Space_Station_3") {
            spaceStation.position = SIMD3<Float>(x: 20, y: -40, z: 40.0)
            spaceStation.scale = SIMD3<Float>(0.03,0.03,0.03)
            spaceStation.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0,1.5,0))
            if let animation = spaceStation.availableAnimations.first {
                spaceStation.playAnimation(animation.repeat())
            }
            
            //环境光
            let environment = try! await EnvironmentResource(named: "Sunlight")
            spaceStation.components[ImageBasedLightComponent.self] = .init(source: .single(environment),intensityExponent: 12)
            spaceStation.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: spaceStation)
            
            content.add(spaceStation)
        }
    }
    
    
    //太空人
    func spaceMan_1(content:any RealityViewContentProtocol) async {
        if let spaceMan = try? await Entity(named: "Animated_Floating_Astronaut_in_Space_Suit_Loop") {
            spaceMan.position = SIMD3<Float>(x: 15, y: 15, z: -70.0)
            spaceMan.scale = SIMD3<Float>(0.005,0.005,0.005)
            spaceMan.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0,-0.1,0))
            if let animation = spaceMan.availableAnimations.first {
                spaceMan.playAnimation(animation.repeat())
            }
            content.add(spaceMan)
        }
    }
    
    func spaceMan_2(content:any RealityViewContentProtocol) async {
        if let spaceMan = try? await Entity(named: "Animated_Floating_Astronaut_in_Space_Suit_Loop") {
            spaceMan.position = SIMD3<Float>(x: 20, y: 0, z: -50.0)
            spaceMan.scale = SIMD3<Float>(0.005,0.005,0.005)
            spaceMan.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0,-0.4,0))
            if let animation = spaceMan.availableAnimations.first {
                spaceMan.playAnimation(animation.repeat())
            }
            content.add(spaceMan)
        }
    }
    
    func spaceMan_3(content:any RealityViewContentProtocol) async {
        if let spaceMan = try? await Entity(named: "Animated_Floating_Astronaut_in_Space_Suit_Loop") {
            spaceMan.position = SIMD3<Float>(x: 30, y: 5, z: -30.0)
            spaceMan.scale = SIMD3<Float>(0.005,0.005,0.005)
            spaceMan.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0,0.95,0))
            if let animation = spaceMan.availableAnimations.first {
                spaceMan.playAnimation(animation.repeat())
            }
            content.add(spaceMan)
        }
    }
    
    //星舰
    func starship(content:any RealityViewContentProtocol) async {
        if let starship = try? await Entity(named: "24_Dizzying_space_travel_-_Inktober2019") {
            starship.position = SIMD3<Float>(x: -30, y: 5, z: 100.0)
            starship.scale = SIMD3<Float>(0.15,0.15,0.15)
            starship.orientation = simd_quatf(angle: .pi, axis: SIMD3<Float>(0,1.1,0))
            if let animation = starship.availableAnimations.first {
                starship.playAnimation(animation.repeat())
            }
            
            //环境光
            let environment = try! await EnvironmentResource(named: "Sunlight")
            starship.components[ImageBasedLightComponent.self] = .init(source: .single(environment),intensityExponent: 12)
            starship.components[ImageBasedLightReceiverComponent.self] = .init(imageBasedLight: starship)
            
            content.add(starship)
        }
    }
    
}

// MARK: - Method
extension ImmersiveView {
    func addGesture(to entity: Entity) {
        entity.components.set(InputTargetComponent())
        entity.generateCollisionShapes(recursive: true)
    }

    private func handleTap() {
        Task {
            await dismissImmersiveSpace()
            await openImmersiveSpace(id: "EarthImmersiveView")
        }
    }
}

#Preview {
    ImmersiveView()
        .previewLayout(.sizeThatFits)
}
