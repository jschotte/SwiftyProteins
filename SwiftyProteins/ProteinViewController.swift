//
//  ProteinViewController.swift
//  SwiftyProteins
//
//  Created by Jeremy SCHOTTE on 2/13/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit
import SceneKit

class ProteinViewController: UIViewController {

    @IBOutlet weak var gameView: SCNView!
    var dataRaw : String = ""
    
    //var gameView:SCNView
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreation:TimeInterval = 0
    
    var ArrayAtoms:[String] = []
    var Atoms:[SCNNode] = []
    
    @IBAction func saveAsImage(_ sender: Any)
    {
        UIImageWriteToSavedPhotosAlbum(gameView.snapshot(), nil,nil,nil)
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
       // print(dataRaw)
        initView()
        initScene()
        initCamera()
        
        ArrayAtoms = dataRaw.components(separatedBy: "\n") as [String]
        
        for atom in ArrayAtoms
        {
            let split = atom.split(separator: " ")
            if (split.count > 0 && split[0] == "ATOM")
            {
                createAtom(pos: SCNVector3(x:Float(split[6])!, y:Float(split[7])!, z:Float(split[8])!), color: getColor(color:String(split[11])))
            }
            else if (split.count > 0 && split[0] == "CONECT")
            {
                for i in 2...split.count-1
                {
                    if (Int(split[1])! - 1 < Atoms.count)
                    {
                        if (Int(split[i])! - 1 < Atoms.count)
                        {
                            print("Link \(split[1]) to \(split[i])")
                            createLink(first: Atoms[Int(split[1])! - 1], second: Atoms[Int(split[i])! - 1])
                        }
                        else
                        {
                            print("Atoms \(Int(split[i])!) don't exitst ")
                        }
                    }
                    else
                    {
                        print("Atoms \(Int(split[1])!) don't exitst ")
                    }
                }
            }

        }
        


    }

    func getColor(color:String) -> UIColor
    {
        switch color {
        case "H":
            return UIColor.white
        case "C":
            return UIColor.lightGray
        case "N":
            return UIColor(red: 0.52, green: 0.80, blue: 0.90, alpha: 1)
        case "O":
            return UIColor.red
        case "F", "Cl":
            return UIColor.green
        case "Br":
            return UIColor(red: 0.55, green: 0, blue: 0, alpha: 1) //dark red
        case "I":
            return UIColor(red: 0.58, green: 0, blue: 0.83, alpha: 1)
        case "He", "Ne", "Ar", "Xe", "Kr":
            return UIColor.cyan
        case "P":
            return UIColor.orange
        case "S":
            return UIColor.yellow
        case "B":
            return UIColor(red: 1, green: 0.85, blue: 0.73, alpha: 1) //peach
        case "Li", "Na", "K", "Rb", "Cs", "Fr":
            return UIColor.purple //violet
        case "Mg", "Be", "Ca", "Sr", "Ba", "Ra":
            return UIColor(red: 0, green: 0.39, blue: 0, alpha: 1) //dark green
        case "Ti":
            return UIColor.gray
        case "Fe":
            return UIColor(red: 1, green: 0.55, blue: 0, alpha: 1)
        default:
            return UIColor(red: 1, green: 0.71, blue: 0.76, alpha: 1)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func initView()
    {
        //gameView = self.view as!SCNView
        gameView.allowsCameraControl = true
        gameView.autoenablesDefaultLighting = true
    }
    
    func initScene()
    {
        gameScene = SCNScene()
        gameView.scene = gameScene
     
        gameView.isPlaying = true
    }
    
    func initCamera()
    {
        cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        
        cameraNode.position = SCNVector3(x:0, y:0, z:10)
        
        //gameScene.rootNode.addChildNode(cameraNode)
    }

    func  createAtom(pos:SCNVector3, color:UIColor)
    {
        let geometry:SCNGeometry = SCNSphere(radius: 0.3)
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = pos
        Atoms.append(geometryNode)
        gameScene.rootNode.addChildNode(geometryNode)

    }
    
    func createLink(first:SCNNode, second:SCNNode)
    {
        let geometryNode = CylinderLine(parent: gameScene.rootNode, v1: first.position, v2: second.position, radius: 0.2, radSegmentCount: 2, color: first.geometry?.materials.first?.diffuse.contents as! UIColor)
        gameScene.rootNode.addChildNode(geometryNode)
        
    }
    
}

class   CylinderLine: SCNNode
{
    init( parent: SCNNode,//Needed to line to your scene
        v1: SCNVector3,//Source
        v2: SCNVector3,//Destination
        radius: CGFloat,// Radius of the cylinder
        radSegmentCount: Int, // Number of faces of the cylinder
        color: UIColor )// Color of the cylinder
    {
        super.init()
        
        //Calcul the height of our line
        let  height = v1.distance(receiver: v2) / 2
        
        //set position to v1 coordonate
        position = v1
        
        //Create the second node to draw direction vector
        let nodeV2 = SCNNode()
        
        //define his position
        nodeV2.position = v2
        //add it to parent
        parent.addChildNode(nodeV2)
        
        //Align Z axis
        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(CGFloat(Double.pi / 2))
        
        //create our cylinder
        let cyl = SCNCylinder(radius: radius, height: CGFloat(height))
        //cyl.radialSegmentCount = radSegmentCount
        cyl.firstMaterial?.diffuse.contents = color
        
        //Create node with cylinder
        let nodeCyl = SCNNode(geometry: cyl )
        nodeCyl.position.y = -height/2
        zAlign.addChildNode(nodeCyl)
        
        //Add it to child
        addChildNode(zAlign)
        
        //set constraint direction to our vector
        constraints = [SCNLookAtConstraint(target: nodeV2)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

private extension SCNVector3{
    func distance(receiver:SCNVector3) -> Float{
        let xd = receiver.x - self.x
        let yd = receiver.y - self.y
        let zd = receiver.z - self.z
        let distance = Float(sqrt(xd * xd + yd * yd + zd * zd))
        
        if (distance < 0){
            return (distance * -1)
        } else {
            return (distance)
        }
    }
}
