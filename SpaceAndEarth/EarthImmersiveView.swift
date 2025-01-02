//
//  EarthImmersiveView.swift
//  SpaceAndEarth
//
//  Created by 达达 on 2024/11/26.
//

import SwiftUI
import RealityKit
import SceneKit

struct EarthImmersiveView: View {
    @State private var viewModel = EarthImmersiveViewModel()
    @State private var textEntity: ModelEntity?
    @State private var dinosaur_cont: AudioPlaybackController?
    @State private var ballnoon_cont: AudioPlaybackController?

    var body: some View {
        RealityView { content in
            
            await addEarthScene(content: content)
            await addDinosaurModel(content: content)
            await addHotAirBallnoonModel(content: content)
            await addTextModel(content: content)
            
            let entity = Entity()
            content.add(entity)
            viewModel.setup(entity: entity)
        }
    }
}

// MARK: - 创建实体
extension EarthImmersiveView {
    func addEarthScene(content:any RealityViewContentProtocol) async {

        let entity = try! await Entity(named: "earth_cliffside")
        entity.position = SIMD3<Float>(0, 1.5, -2)
        entity.scale = SIMD3<Float>(4, 4, 4)
        content.add(entity)

    }
    // 添加恐龙
    func addDinosaurModel(content:any RealityViewContentProtocol) async {
        
        // 三角龙-右下方
        let dinosaur2 = await creatDinosaurEntity(
            name: "dinosaur2",
            position: SIMD3<Float>(55, -150, 0),
            scale: SIMD3<Float>(0.1, 0.1, 0.1),
            orientation: simd_quatf(angle: .pi*0.1, axis: SIMD3<Float>(0, 1, 0))
        )
        // 双角龙-右下方
        let dinosaur7_1 = await creatDinosaurEntity(
            name: "dinosaur7",
            position: SIMD3<Float>(90, -150, 50),
            scale: SIMD3<Float>(0.1, 0.1, 0.1),
            orientation: simd_quatf(angle: .pi*0.4, axis: SIMD3<Float>(0, 1, 0))

        )
        let dinosaur7_2 = await creatDinosaurEntity(
            name: "dinosaur7",
            position: SIMD3<Float>(80, -150, 75),
            scale: SIMD3<Float>(0.1, 0.1, 0.1)
        )
        
        // 霸王龙-右上方
        let dinosaur3 = await creatDinosaurEntity(
            name: "dinosaur3",
            position: SIMD3<Float>(530, -25, 35),
            scale: SIMD3<Float>(0.15, 0.15, 0.15),
            orientation: simd_quatf(angle: .pi*1, axis: SIMD3<Float>(0, 1, 0))
        )

        // 腕龙-左上方
        let dinosaur1 = await creatDinosaurEntity(
            name: "dinosaur1",
            position: SIMD3<Float>(-140, -40, -70),
            scale: SIMD3<Float>(0.1, 0.1, 0.1),
            orientation: simd_quatf(angle: .pi*0.8, axis: SIMD3<Float>(0, 1, 0))
        )
        // 中间
        let dinosaur6_1 = await creatDinosaurEntity(
            name: "dinosaur6",
            position: SIMD3<Float>(0, 10, -300),
            scale: SIMD3<Float>(0.1, 0.1, 0.1),
            orientation: simd_quatf(angle: .pi*0, axis: SIMD3<Float>(0, 1, 0))
        )
        // 右
        let dinosaur6_2 = await creatDinosaurEntity(
            name: "dinosaur6",
            position: SIMD3<Float>(150, 4, -100),
            scale: SIMD3<Float>(0.1, 0.1, 0.1),
            orientation: simd_quatf(angle: .pi*1.4, axis: SIMD3<Float>(0, 1, 0))
        )
        // 左
        let dinosaur6_3 = await creatDinosaurEntity(
            name: "dinosaur6",
            position: SIMD3<Float>(-100, 24, -100),
            scale: SIMD3<Float>(0.1, 0.1, 0.1),
            orientation: simd_quatf(angle: .pi*0.3, axis: SIMD3<Float>(0, 1, 0))
        )
        
        content.add(dinosaur1)
        content.add(dinosaur2)
        content.add(dinosaur3)
        
        content.add(dinosaur6_1)
        content.add(dinosaur6_2)
        content.add(dinosaur6_3)

        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            addMoveAnimation(
                to: dinosaur6_1,
                startPosition: SIMD3<Float>(0, 10, -300),
                endPosition: SIMD3<Float>(0, -40, 300),
                duration: 55.0
            )
            addMoveAnimation(
                to: dinosaur6_2,
                startPosition: SIMD3<Float>(150, 8, -100),
                endPosition: SIMD3<Float>(-700, 4, -100),
                duration:50.0
            )
        }
        
        content.add(dinosaur7_1)
        content.add(dinosaur7_2)

        // 加载并播放音频资源
        if let audioResource = try? AudioFileResource.load(named: "dinosaur_call1") {
            let audioEntity = Entity()
            let audioController = audioEntity.prepareAudio(audioResource)
            audioController.play()
            audioController.completionHandler = {
                audioController.play()
            }
            content.add(audioEntity)
            self.dinosaur_cont = audioController
        }
        
    }
    
    // 添加热气球
    func addHotAirBallnoonModel(content:any RealityViewContentProtocol) async {
        let entity = try! await Entity(named: "earth_Hot_Air_Balloon_Loo")
        await addLightAndAnimation(to: entity)
        entity.position = SIMD3<Float>(500, 60, -200)
        entity.scale = SIMD3<Float>(0.5, 0.5, 0.5)

        content.add(entity)
        // 加载并播放音频资源
        if let audioResource = try? AudioFileResource.load(named: "airplaneSound") {
            let audioEntity = Entity()
            let audioController = audioEntity.prepareAudio(audioResource)
            audioController.pause()
            audioController.completionHandler = {
                audioController.play()
            }
            content.add(audioEntity)
            self.ballnoon_cont = audioController

        }

        entity.orientation = simd_quatf(angle: .pi*0.2, axis: SIMD3<Float>(0, 1, 0))
        
        let duration: TimeInterval = 40
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            addMoveAnimation(
                to: entity,
                startPosition: entity.position,
                endPosition: SIMD3<Float>(0, 3, -20),
                duration: duration)
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+duration-23) {
            self.dinosaur_cont?.pause()
            self.ballnoon_cont?.play()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+duration) {
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 2.0 // 设置动画持续时间
            entity.orientation = simd_quatf(angle: .pi * 0.5, axis: SIMD3<Float>(0, 1, 0))
            SCNTransaction.commit()
        }
        /*
        Hello!欢迎来到 恐龙 世界，你愿意 和 我一起 体验这次 侏罗纪旅行吗?
        what !很抱歉，噪音太大了，我听不到你说什么~
        Look ! 有人在朝我招手 ，我要走了，那我们下次再见 ~
        Bye Bye ....
         */
        DispatchQueue.main.asyncAfter(deadline: .now()+duration+5) {
            updateTextModel(text: "Hello!欢迎来到 恐龙 世界，\n你愿意 和 我一起 体验这次 侏罗纪旅行吗?")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+duration+15) {
            updateTextModel(text: "what !很抱歉，\n噪音太大了，我听不到你说什么~")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+duration+25) {
            updateTextModel(text: "Look ! 有人在朝我招手\n我要走了，那我们下次再见 ~")
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+duration+35) {
            updateTextModel(text: "Bye Bye ....")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+duration+40) {
            entity.orientation = simd_quatf(angle: .pi*0.3, axis: SIMD3<Float>(0, 1, 0))
            self.textEntity?.isEnabled = false
            
            addMoveAnimation(
                to: entity,
                startPosition: entity.position,
                endPosition: SIMD3<Float>(-30, 3, -20),
                rotation: simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)),
                duration: 5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now()+duration+45) {
            entity.orientation = simd_quatf(angle: .pi*0.3, axis: SIMD3<Float>(0, 1, 0))
            self.textEntity?.isEnabled = false
            
            addMoveAnimation(
                to: entity,
                startPosition: entity.position,
                endPosition: SIMD3<Float>(-300, 40, 700),
                rotation: simd_quatf(angle: .pi, axis: SIMD3<Float>(0, 1, 0)),
                duration: duration+40)
        }
                
        DispatchQueue.main.asyncAfter(deadline: .now()+duration+63) {
            self.dinosaur_cont?.play()
            self.ballnoon_cont?.pause()
        }
        
    }
    
    // 创建文字
    func addTextModel(content:any RealityViewContentProtocol) async {
        // 创建字体
        let textMesh = MeshResource.generateText("")
        var material = SimpleMaterial()
        material.color = .init(tint: .white)
        let textEntity = ModelEntity(mesh: textMesh, materials: [material])
        textEntity.position = SIMD3(-3, 0.8, -10)
        content.add(textEntity)
        self.textEntity = textEntity
        textEntity.isEnabled = false
    }
    
    func updateTextModel(text: String) {
        textEntity?.isEnabled = true
        let textMesh = MeshResource.generateText(
            text,
            extrusionDepth: 0.01,
            font: .systemFont(ofSize: 0.5),
            containerFrame: .zero,
            alignment: .left,
            lineBreakMode: .byWordWrapping
        )
        self.textEntity?.model?.mesh = textMesh
    }
    
    // 添加恐龙实体
    func creatDinosaurEntity(name: String,
                             position: SIMD3<Float>,
                             scale: SIMD3<Float> = SIMD3<Float>(0.03, 0.03, 0.03),
                             orientation: simd_quatf = simd_quatf()
    ) async -> Entity {
        let entity = try! await Entity(named: name)
        await addLightAndAnimation(to: entity)
        entity.position = position
        entity.scale = scale
        entity.orientation = orientation
        
        return entity
    }
    
    
}

// MARK: - Method
extension EarthImmersiveView {
    // 添加灯光&动画的函数
    func addLightAndAnimation(to entity: Entity) async {
        // 添加动画
        if let animation = entity.availableAnimations.first {
            entity.playAnimation(animation.repeat())
        }
        
        // 添加光源
        let lightEntity = Entity()
        
        var lightComponent = DirectionalLightComponent()
        lightComponent.intensity = 520
        lightComponent.color = .white
        
        lightEntity.components[DirectionalLightComponent.self] = lightComponent
        lightEntity.position = SIMD3<Float>(0, 10, 0)
        lightEntity.look(at: entity.position, from: lightEntity.position, relativeTo: nil)
        
        entity.addChild(lightEntity)
    }
    
    // 添加移动动画
    func addMoveAnimation(to entity: Entity, startPosition: SIMD3<Float>, endPosition: SIMD3<Float>, rotation: simd_quatf? = nil, duration: TimeInterval = 5.0) {
        var rotation = rotation
        if rotation == nil {
            rotation = entity.transform.rotation
        }
        
        // 创建从起始位置到结束位置的动画
        let moveForward = Transform(
            scale: entity.transform.scale,
            rotation: entity.transform.rotation,
            translation: endPosition
        )
        // 创建动画控制器
        entity.move(to: moveForward, relativeTo: entity.parent, duration: duration, timingFunction: .linear)
    }
}

#Preview {
    EarthImmersiveView()
}
