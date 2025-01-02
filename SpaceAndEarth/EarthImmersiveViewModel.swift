//
//  EarthImmersiveViewModel.swift
//  SpaceAndEarth
//
//  Created by 达达 on 2024/11/26.
//

import RealityKit
import GameplayKit

struct GameObject {
    var entity: Entity!
    var agent = GKAgent3D()

    init(entity: Entity) {
        self.entity = entity
    }

    func setPosition(_ position: SIMD3<Float>) {
        entity.position = position
        agent.position = position
    }
}

final class EarthImmersiveViewModel: NSObject, GKAgentDelegate {

    var rootEntity: Entity!
    var animationTime: TimeInterval = 0

    private(set) var target: GameObject!
    private(set) var ships: [GameObject] = []
    private(set) var agentSystem = GKComponentSystem(componentClass: GKAgent3D.self)

    let targetPositions: [(TimeInterval, SIMD3<Float>)] = [
        (2.0, SIMD3<Float>(0, 2.0, -10)),
        (4.0, SIMD3<Float>(-5, 2.0, -10)),
        (6.0, SIMD3<Float>(-9, 3.0, -10)),
        (8.0, SIMD3<Float>(-3.0, 3.0, -12)),
    ]

    func setup(entity: Entity) {
        rootEntity = entity

//        let baseEntity = creatBaseEntity()
//        
//        setupTarget()
//        setupShips(ship: baseEntity)
    }

    func agentDidUpdate(_ agent: GKAgent) {
        guard let agent = agent as? GKAgent3D else { return }
        let gameObject = self.ships.first(where: { $0.agent === agent })
        gameObject?.entity.transform.matrix = agent.transform
    }

    private func creatBaseEntity() -> Entity {
        let baseEntity = try! ModelEntity.load(named: "phoenix_bird")
        if let animation = baseEntity.availableAnimations.first {
            baseEntity.playAnimation(animation.repeat())
        }
        // 加载并播放音频资源
        if let audioResource = try? AudioFileResource.load(named: "phoenix_call") {
            let audioEntity = Entity()
            let audioController = audioEntity.prepareAudio(audioResource)
            audioController.play()
            audioController.completionHandler = {
                audioController.play()
            }
            
            baseEntity.addChild(audioEntity)
        }
        
        return baseEntity
    }
    
    private func setupTarget() {
        let entity = Entity()
        // 气球图
        let modelComponent = ModelComponent(
            mesh: .generateSphere(radius: 0.001),
            materials: [SimpleMaterial(color: .init(red: 1.0, green: 0.84, blue: 0.0, alpha: 0.6), roughness: 0.5, isMetallic: true)]
        )
        entity.components.set(modelComponent)

        entity.position = targetPositions[0].1
        rootEntity.addChild(entity)

        let gameObject = GameObject(entity: entity)
        gameObject.agent.position = entity.position
        gameObject.agent.radius = 0.2

        agentSystem.addComponent(gameObject.agent)
        target = gameObject
    }

    private func addShip(baseShip: Entity, offsetPosition: SIMD3<Float>) {
        let entity = Entity()
        entity.position = baseShip.position + offsetPosition

        let ship = baseShip.clone(recursive: true)
        ship.orientation *= simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(0, 0, 1))
        entity.addChild(ship)

        entity.components.set(EarthChaserComponent(viewModel: self))

        rootEntity.addChild(entity)
        ships.append(GameObject(entity: entity))
    }
    
    func addBirdShip(baseShip: Entity, offsetPosition: SIMD3<Float>) {
        let entity = Entity()
        entity.position = baseShip.position + offsetPosition

//        let ship = baseShip.clone(recursive: true)
//        ship.orientation *= simd_quatf(angle: -.pi / 2, axis: SIMD3<Float>(0, 0, 1))
        entity.addChild(baseShip)

        entity.components.set(EarthChaserComponent(viewModel: self))

        rootEntity.addChild(entity)
        ships.append(GameObject(entity: entity))
    }


    private func setupShips(ship: Entity) {

        addBirdShip(baseShip: ship, offsetPosition: [4, 0.0, -4])
        
        let agents = ships.map { $0.agent }
        let avoid = GKGoal(toAvoid: agents, maxPredictionTime: 3)

        ships.forEach() {
            $0.agent.maxAcceleration = Float.random(in: 2...5)
            $0.agent.maxSpeed = Float.random(in: 2...5)
            $0.agent.position = $0.entity.position
            $0.agent.rotation = simd_float3x3(
                SIMD3<Float>( 0, 0, -1),
                SIMD3<Float>( 0, 1, 0),
                SIMD3<Float>( 1, 0, 0))
            $0.agent.radius = 0.1
            $0.agent.delegate = self
            $0.agent.behavior = GKBehavior(goals: [GKGoal(toSeekAgent: target.agent), avoid])
            $0.entity.isEnabled = true
            agentSystem.addComponent($0.agent)
        }
    }
}

struct EarthChaserComponent: Component {
    weak var viewModel: EarthImmersiveViewModel?
    let animationSpeedFactor = 6.0
    let animationEndTime = 16.0

    init(viewModel: EarthImmersiveViewModel) {
        self.viewModel = viewModel
    }
}

class EarthChaserSystem : System {
    static let query = EntityQuery(where: .has(EarthChaserComponent.self))

    required init(scene: RealityKit.Scene) {}

    func update(context: SceneUpdateContext) {
        for entity in context.entities(matching: Self.query, updatingSystemWhen: .rendering) {
            let chaser: EarthChaserComponent = entity.components[EarthChaserComponent.self]!
            defer { entity.components[EarthChaserComponent.self] = chaser }

            guard let viewModel = chaser.viewModel else { continue }
            let targetPosition = viewModel.targetPositions.first(where: { $0.0 > viewModel.animationTime })?.1
            if let pos = targetPosition {
                viewModel.target.setPosition(pos)
            }
            viewModel.animationTime += context.deltaTime / chaser.animationSpeedFactor
            viewModel.agentSystem.update(deltaTime: context.deltaTime / chaser.animationSpeedFactor)

            if viewModel.animationTime > chaser.animationEndTime {
                viewModel.animationTime = 0.0
            }
        }
    }
}

extension GKAgent3D {
    var transform: simd_float4x4 {
        simd_float4x4(simd_float4(rotation.columns.0, 0),
                      simd_float4(rotation.columns.1, 0),
                      simd_float4(rotation.columns.2, 0),
                      simd_float4(position, 1))
    }
}
