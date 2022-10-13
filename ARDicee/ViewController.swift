//
//  ViewController.swift
//  ARDicee
//
//  Created by Mauricio Contreras on 05/10/22.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.autoenablesDefaultLighting = true
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        // add plane detectation in the app
        configuration.planeDetection = .horizontal
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    //MARK: - DicerenderingMethods
    // loacion in the real world.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first {
                addDicee(atLocation: hitResult)
            }
        }
    }
    
    func addDicee(atLocation location: ARHitTestResult){
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        // recursively: true have other child node in the code
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
            diceNode.position = SCNVector3(
                x: location.worldTransform.columns.3.x,
                y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
                z: location.worldTransform.columns.3.z)
            
            diceArray.append(diceNode)
            
            sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
        }
    }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray{
                roll(dice : dice)
            }
        }
    }
    
    func roll(dice: SCNNode){
        // Generate Movement in the dice
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
        
        //Animation
        dice.runAction(
            SCNAction.rotateBy(
                x: CGFloat(randomX * 5),
                y: 0,
                z: CGFloat(randomZ * 5),
                duration: 0.5)
        )
    }
    
    @IBAction func rollAgain(_ sender: Any) {
        rollAll()
    }
    
    // move phone to shake.
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    // Bar Button Item Deleted
    @IBAction func removeAllDice(_ sender: Any) {
        if !diceArray.isEmpty{
            for dice in diceArray{
                dice.removeFromParentNode()
            }
        }
    }
    
    //MARK: - ARSCNViewDelagetMethods
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor is ARPlaneAnchor{
            print("Plane detected")
            let planeAnchor = anchor as! ARPlaneAnchor
            let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
            // create plane note
            let planeNode = SCNNode()
            planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
            //Specifi Width and height and transform
            planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
            // Specifi a Material.
            let gridMaterial = SCNMaterial()
            gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
            plane.materials = [gridMaterial]
            planeNode.geometry = plane
            // add node
            node.addChildNode(planeNode)
            
        } else {
            return
        }
    }
}
