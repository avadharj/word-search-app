//
//  CubeView.swift
//  Final_Project-23
//
//  Created by Arjun Avadhani on 11/15/25.
//

import SwiftUI
import SceneKit
import QuartzCore
import UIKit

struct CubeView: UIViewRepresentable {
    @ObservedObject var gameState: GameState
    @ObservedObject private var motionManager = MotionManager.shared
    let onLetterSelected: (Int) -> Void
    
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        let scene = createScene()
        sceneView.scene = scene
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.systemGroupedBackground
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.allowsCameraControl = false
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePan(_:)))
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handlePinch(_:)))
        sceneView.addGestureRecognizer(pinchGesture)
        
        context.coordinator.sceneView = sceneView
        context.coordinator.gameState = gameState
        context.coordinator.onLetterSelected = onLetterSelected
        context.coordinator.cameraNode = scene.rootNode.childNodes.first { $0.camera != nil }
        context.coordinator.initialCameraDistance = 8.0
        context.coordinator.motionManager = motionManager
        
        motionManager.startMotionUpdates()
        context.coordinator.startMotionUpdates()
        
        updateCubeVisualization(in: scene, gameState: gameState, coordinator: context.coordinator)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = uiView.scene {
            updateCubeVisualization(in: scene, gameState: gameState, coordinator: context.coordinator)
        }
        context.coordinator.gameState = gameState
        context.coordinator.motionManager = motionManager
    }
    
    static func dismantleUIView(_ uiView: SCNView, coordinator: Coordinator) {
        coordinator.stopMotionUpdates()
    }
    
    private func createScene() -> SCNScene {
        let scene = SCNScene()
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 60
        cameraNode.position = SCNVector3(x: 4, y: 4, z: 6)
        cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(cameraNode)
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.white.withAlphaComponent(0.8)
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        let directionalLight1 = SCNLight()
        directionalLight1.type = .directional
        directionalLight1.color = UIColor.white
        directionalLight1.intensity = 1000
        let directionalNode1 = SCNNode()
        directionalNode1.light = directionalLight1
        directionalNode1.position = SCNVector3(x: 5, y: 5, z: 5)
        directionalNode1.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(directionalNode1)
        
        let directionalLight2 = SCNLight()
        directionalLight2.type = .directional
        directionalLight2.color = UIColor.white.withAlphaComponent(0.5)
        directionalLight2.intensity = 500
        let directionalNode2 = SCNNode()
        directionalNode2.light = directionalLight2
        directionalNode2.position = SCNVector3(x: -5, y: -3, z: -5)
        directionalNode2.look(at: SCNVector3(x: 0, y: 0, z: 0))
        scene.rootNode.addChildNode(directionalNode2)
        
        return scene
    }
    
    private func updateCubeVisualization(in scene: SCNScene?, gameState: GameState, coordinator: Coordinator) {
        guard let scene = scene else { return }
        
        scene.rootNode.childNodes.filter { $0.name?.hasPrefix("letterNode_") == true || $0.name == "cubeNode" }.forEach { $0.removeFromParentNode() }
        
        coordinator.nodeIndexMap.removeAll()
        
        let cube = gameState.cube
        let spacing: Float = 1.2
        
        for (index, letter) in cube.letters.enumerated() {
            let letterNode = createLetterNode(
                letter: letter,
                index: index,
                isSelected: gameState.selectedIndices.contains(index),
                spacing: spacing,
                coordinator: coordinator
            )
            scene.rootNode.addChildNode(letterNode)
        }
    }
    
    private func createLetterNode(letter: Letter, index: Int, isSelected: Bool, spacing: Float, coordinator: Coordinator) -> SCNNode {
        let node = SCNNode()
        node.name = "letterNode_\(index)"
        node.position = SCNVector3(
            letter.position.x * spacing,
            letter.position.y * spacing,
            letter.position.z * spacing
        )
        
        let boxSize: CGFloat = 0.8
        let box = SCNBox(width: boxSize, height: boxSize, length: boxSize, chamferRadius: 0.15)
        let boxMaterial = SCNMaterial()
        
        if letter.isRemoved {
            boxMaterial.diffuse.contents = UIColor.systemGray
            boxMaterial.emission.contents = UIColor.systemGray.withAlphaComponent(0.2)
        } else if isSelected {
            boxMaterial.diffuse.contents = UIColor.systemBlue
            boxMaterial.emission.contents = UIColor.systemBlue.withAlphaComponent(0.5)
        } else {
            boxMaterial.diffuse.contents = UIColor.white
            boxMaterial.emission.contents = UIColor.white.withAlphaComponent(0.3)
        }
        boxMaterial.specular.contents = UIColor.white
        boxMaterial.lightingModel = .lambert
        box.firstMaterial = boxMaterial
        
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(0, 0, 0)
        
        if isSelected && !letter.isRemoved {
            let scaleUp = SCNAction.scale(to: 1.15, duration: 0.2)
            let scaleDown = SCNAction.scale(to: 1.0, duration: 0.2)
            let pulse = SCNAction.sequence([scaleUp, scaleDown])
            boxNode.runAction(SCNAction.repeatForever(pulse), forKey: "selectionPulse")
        }
        
        if letter.isRemoved {
            let fadeOut = SCNAction.fadeOut(duration: 0.5)
            let scaleDown = SCNAction.scale(to: 0.1, duration: 0.5)
            let remove = SCNAction.removeFromParentNode()
            let sequence = SCNAction.sequence([SCNAction.group([fadeOut, scaleDown]), remove])
            node.runAction(sequence)
        }
        
        let textImage = createTextImage(character: letter.character, isSelected: isSelected, isRemoved: letter.isRemoved)
        let textPlane = SCNPlane(width: 0.6, height: 0.6)
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = textImage
        textMaterial.isDoubleSided = true
        textMaterial.lightingModel = .constant
        textPlane.firstMaterial = textMaterial
        
        let textNode = SCNNode(geometry: textPlane)
        textNode.position = SCNVector3(0, 0, Float(boxSize) / 2 + 0.01)
        textNode.eulerAngles = SCNVector3(0, 0, 0)
        
        boxNode.name = "letterBox_\(index)"
        textNode.name = "letterText_\(index)"
        
        node.addChildNode(boxNode)
        node.addChildNode(textNode)
        
        coordinator.nodeIndexMap[node] = index
        coordinator.nodeIndexMap[boxNode] = index
        coordinator.nodeIndexMap[textNode] = index
        
        return node
    }
    
    private func createTextImage(character: Character, isSelected: Bool, isRemoved: Bool = false) -> UIImage {
        let size = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            var bgColor: UIColor
            var textColor: UIColor
            
            if isRemoved {
                bgColor = UIColor.systemGray
                textColor = UIColor.systemGray3
            } else if isSelected {
                bgColor = UIColor.systemBlue
                textColor = UIColor.white
            } else {
                bgColor = UIColor.white
                textColor = UIColor.black
            }
            
            bgColor.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            let text = String(character).uppercased()
            let font = UIFont.systemFont(ofSize: 120, weight: .bold)
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: textColor,
                .paragraphStyle: paragraphStyle
            ]
            
            let textRect = CGRect(x: 0, y: (size.height - font.lineHeight) / 2, width: size.width, height: size.height)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        var sceneView: SCNView?
        var gameState: GameState?
        var onLetterSelected: ((Int) -> Void)?
        var nodeIndexMap: [SCNNode: Int] = [:]
        var lastPanLocation: CGPoint?
        var cameraNode: SCNNode?
        var initialCameraDistance: Float = 8.0
        var motionManager: MotionManager?
        var motionUpdateTimer: CADisplayLink?
        
        var motionRotationX: Float = 0.0
        var motionRotationY: Float = 0.0
        
        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = sceneView,
                  let gameState = gameState,
                  gesture.state == .ended else { return }
            
            let location = gesture.location(in: sceneView)
            
            let hitTestOptions: [SCNHitTestOption: Any] = [
                .searchMode: SCNHitTestSearchMode.all.rawValue,
                .ignoreHiddenNodes: false,
                .backFaceCulling: false
            ]
            
            let hitResults = sceneView.hitTest(location, options: hitTestOptions)
            
            for hitResult in hitResults {
                var foundIndex: Int?
                
                if let index = nodeIndexMap[hitResult.node] {
                    foundIndex = index
                } else if let parent = hitResult.node.parent,
                          let index = nodeIndexMap[parent] {
                    foundIndex = index
                }
                
                if foundIndex == nil {
                    if let nodeName = hitResult.node.name {
                        if nodeName.hasPrefix("letterBox_") || nodeName.hasPrefix("letterText_") || nodeName.hasPrefix("letterNode_") {
                            if let indexString = nodeName.components(separatedBy: "_").last,
                               let index = Int(indexString) {
                                foundIndex = index
                            }
                        }
                    }
                    
                    if foundIndex == nil, let parent = hitResult.node.parent,
                       let parentName = parent.name {
                        if parentName.hasPrefix("letterBox_") || parentName.hasPrefix("letterNode_") {
                            if let indexString = parentName.components(separatedBy: "_").last,
                               let index = Int(indexString) {
                                foundIndex = index
                            }
                        }
                    }
                }
                
                if let index = foundIndex {
                    onLetterSelected?(index)
                    return
                }
            }
        }
        
        @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
            guard let sceneView = sceneView,
                  let cameraNode = cameraNode else { return }
            
            let translation = gesture.translation(in: sceneView)
            let velocity = gesture.velocity(in: sceneView)
            
            if abs(velocity.x) > 50 || abs(velocity.y) > 50 || gesture.state == .changed {
                let rotationSpeed: Float = 0.01
                let deltaX = Float(translation.x) * rotationSpeed
                let deltaY = Float(translation.y) * rotationSpeed
                
                let rotationY = SCNMatrix4MakeRotation(deltaX, 0, 1, 0)
                let rotationX = SCNMatrix4MakeRotation(-deltaY, 1, 0, 0)
                
                let currentPosition = cameraNode.position
                var newPosition = SCNVector3(
                    currentPosition.x * rotationY.m11 + currentPosition.z * rotationY.m13,
                    currentPosition.y,
                    currentPosition.x * rotationY.m31 + currentPosition.z * rotationY.m33
                )
                
                let distance = sqrt(newPosition.x * newPosition.x + newPosition.y * newPosition.y + newPosition.z * newPosition.z)
                newPosition.y = max(-distance * 0.8, min(distance * 0.8, newPosition.y - deltaY * distance))
                
                let normalized = normalize(newPosition)
                cameraNode.position = SCNVector3(
                    normalized.x * initialCameraDistance,
                    normalized.y * initialCameraDistance,
                    normalized.z * initialCameraDistance
                )
                cameraNode.look(at: SCNVector3(0, 0, 0))
                
                gesture.setTranslation(.zero, in: sceneView)
            }
        }
        
        @objc func handlePinch(_ gesture: UIPinchGestureRecognizer) {
            guard let cameraNode = cameraNode else { return }
            
            if gesture.state == .changed {
                let scale = Float(gesture.scale)
                initialCameraDistance = initialCameraDistance / scale
                initialCameraDistance = max(5.0, min(15.0, initialCameraDistance))
                
                let normalized = normalize(cameraNode.position)
                cameraNode.position = SCNVector3(
                    normalized.x * initialCameraDistance,
                    normalized.y * initialCameraDistance,
                    normalized.z * initialCameraDistance
                )
                
                gesture.scale = 1.0
            }
        }
        
        private func normalize(_ vector: SCNVector3) -> SCNVector3 {
            let length = sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z)
            guard length > 0 else { return SCNVector3(0, 0, 1) }
            return SCNVector3(vector.x / length, vector.y / length, vector.z / length)
        }
        
        func startMotionUpdates() {
            guard motionUpdateTimer == nil else { return }
            
            motionUpdateTimer = CADisplayLink(target: self, selector: #selector(updateMotionCamera))
            motionUpdateTimer?.preferredFramesPerSecond = 60
            motionUpdateTimer?.add(to: .main, forMode: .common)
        }
        
        func stopMotionUpdates() {
            motionUpdateTimer?.invalidate()
            motionUpdateTimer = nil
            motionManager?.stopMotionUpdates()
        }
        
        @objc private func updateMotionCamera() {
            guard let motionManager = motionManager,
                  let cameraNode = cameraNode,
                  motionManager.motionEnabled else {
                return
            }
            
            let rotationDelta = motionManager.getRotationDelta()
            
            motionRotationX += Float(rotationDelta.x)
            motionRotationY += Float(rotationDelta.y)
            
            motionRotationY = max(-Float.pi / 3, min(Float.pi / 3, motionRotationY))
            
            let basePosition = SCNVector3(
                sin(motionRotationX) * cos(motionRotationY) * initialCameraDistance,
                sin(motionRotationY) * initialCameraDistance,
                cos(motionRotationX) * cos(motionRotationY) * initialCameraDistance
            )
            
            cameraNode.position = basePosition
            cameraNode.look(at: SCNVector3(0, 0, 0))
            
            if motionManager.isShaking() {
                handleShake()
            }
        }
        
        private func handleShake() {
            motionRotationX = 0.0
            motionRotationY = 0.0
            
            let defaultPosition = SCNVector3(4, 4, 6)
            let moveAction = SCNAction.move(to: defaultPosition, duration: 0.5)
            moveAction.timingMode = .easeInEaseOut
            cameraNode?.runAction(moveAction)
            
            SoundManager.shared.playHaptic(.medium)
        }
    }
}
