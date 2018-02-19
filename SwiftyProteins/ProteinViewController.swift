//
//  ProteinViewController.swift
//  SwiftyProteins
//
//  Created by Jeremy SCHOTTE on 2/13/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit
import SceneKit

class ProteinViewController: UIViewController
{

    @IBOutlet weak var gameView: SCNView!
    var dataRaw : String = ""
    
    //var gameView:SCNView
    var gameScene:SCNScene!
    var cameraNode:SCNNode!
    var targetCreation:TimeInterval = 0
    
    @IBOutlet weak var labelAtom: UILabel!
    var ArrayAtoms:[String] = []
    
    var Atoms:[SCNNode] = []
    var Link:[SCNNode] = []
    
    @IBAction func share(_ sender: Any)
    {
        let activityVc = UIActivityViewController(activityItems: [gameView.snapshot()], applicationActivities: nil)
        activityVc.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVc, animated: true, completion: nil)
    }
    
    @IBAction func saveAsImage(_ sender: Any)
    {
        
        UIImageWriteToSavedPhotosAlbum(gameView.snapshot(), nil,nil,nil)
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        initView()
        initScene()
        initCamera()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        
        let doubletap = UITapGestureRecognizer(target: self, action: #selector(handleTap(rec:)))
        

        doubletap.numberOfTapsRequired = 2
        
        gameView.addGestureRecognizer(tap)
        gameView.addGestureRecognizer(doubletap)

        ArrayAtoms = dataRaw.components(separatedBy: "\n") as [String]
        
        for atom in ArrayAtoms
        {
            let split = atom.split(separator: " ")
            if (split.count > 0 && split[0] == "ATOM")
            {
                createAtom(pos: SCNVector3(x:Float(split[6])!, y:Float(split[7])!, z:Float(split[8])!), color: getColor(color:String(split[11])), name: String(split[11]))
            }
            else if (split.count > 0 && split[0] == "CONECT")
            {
                for i in 2...split.count-1
                {
                    if (Int(split[1])! - 1 < Atoms.count)
                    {
                        if (Int(split[i])! - 1 < Atoms.count)
                        {
                            //print("Link \(split[1]) to \(split[i])")
                            createLink(first: Atoms[Int(split[1])! - 1], second: Atoms[Int(split[i])! - 1])
                        }
                        else
                        {
                            //print("Atoms \(Int(split[i])!) don't exitst ")
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
    
    override func viewDidDisappear(_ animated: Bool)
    {
        gameView.isPlaying = false
        
        if isMovingFromParentViewController
        {
            gameView.pointOfView = nil
        }
        
        
        print("quit")
    }
    
    @IBOutlet weak var ballSwitch: UISwitch!
    @IBOutlet weak var stickSwitch: UISwitch!
    
    @objc func handleTap(rec: UITapGestureRecognizer)
    {
       // print("click atom")
        if rec.state == .ended
        {
            let location: CGPoint = rec.location(in: gameView)
            let hits = self.gameView.hitTest(location, options: nil)
            if !hits.isEmpty
            {
                let tappedNode = hits.first?.node
                if tappedNode?.geometry is SCNSphere || tappedNode?.geometry is SCNCylinder
                {
                    if (rec.numberOfTapsRequired == 2)
                    {
                        print("double tap")
                        for node in Atoms
                        {
                            if node.name != tappedNode?.name
                            {
                                node.opacity = 0.2
                            }
                        }
                        for node in Link
                        {
                            if node.name != tappedNode?.name
                            {
                                node.opacity = 0.2
                            }
                        }
                    }
                    else
                    {
                        labelAtom.text = "Atom selected: \(String(describing: (tappedNode?.name)!))"
                        
                        for node in Atoms
                        {
                            node.opacity = 1
                        }
                        for node in Link
                        {
                            node.opacity = 1
                        }
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
    
    @IBAction func changeBallsState(_ sender: UISwitch)
    {
        if (sender.isOn)
        {
            stickSwitch.isEnabled = false
            for node in Atoms
            {
                node.isHidden = true
            }
        }
        else
        {
            stickSwitch.isEnabled = true
            for node in Atoms
            {
                node.isHidden = false
            }
        }
    }
    
    @IBAction func changeStickState(_ sender: UISwitch)
    {
        if (sender.isOn)
        {
            ballSwitch.isEnabled = false
            for node in Link
            {
                node.isHidden = true
            }
            for atom in Atoms
            {
                atom.scale =  SCNVector3 (3.5, 3.5, 3.5)
            }
        }
        else
        {
            ballSwitch.isEnabled = true
            for node in Link
            {
                node.isHidden = false
            }
            for atom in Atoms
            {
                atom.scale =  SCNVector3 (1.0, 1.0, 1.0)
            }
        }
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

    func  createAtom(pos:SCNVector3, color:UIColor, name: String)
    {
        let geometry:SCNGeometry = SCNSphere(radius: 0.3)
        geometry.materials.first?.diffuse.contents = color
        
        let geometryNode = SCNNode(geometry: geometry)
        geometryNode.position = pos
        geometryNode.name = name
        Atoms.append(geometryNode)
        gameScene.rootNode.addChildNode(geometryNode)

    }
    
    func createLink(first:SCNNode, second:SCNNode)
    {
        let geometryNode = CylinderLine(parent: gameScene.rootNode, v1: first.position, v2: second.position, radius: 0.1, radSegmentCount: 2, color: first.geometry?.materials.first?.diffuse.contents as! UIColor, nameLink: first.name!)
        
        for node in geometryNode.childNodes
        {
            node.name = first.name
        }
        geometryNode.name = first.name
        gameScene.rootNode.addChildNode(geometryNode)

        Link.append(geometryNode)

    }
}

class   CylinderLine: SCNNode
{
    init( parent: SCNNode,
        v1: SCNVector3,
        v2: SCNVector3,
        radius: CGFloat,
        radSegmentCount: Int,
        color: UIColor,
        nameLink: String)
    {
        super.init()
        
        let  height = v1.distance(receiver: v2) / 2
        position = v1
        
        let nodeV2 = SCNNode()
        nodeV2.position = v2
        parent.addChildNode(nodeV2)

        let zAlign = SCNNode()
        zAlign.eulerAngles.x = Float(CGFloat(Double.pi / 2))
        zAlign.eulerAngles.z = -Float(CGFloat(Double.pi / 2))

        let cyl = SCNCylinder(radius: radius, height: CGFloat(height))
        cyl.firstMaterial?.diffuse.contents = color
        cyl.name = nameLink
        
        let nodeCyl = SCNNode(geometry: cyl )
        nodeCyl.position.y = -height/2
        nodeCyl.name = nameLink
        
        zAlign.name = nameLink
        zAlign.addChildNode(nodeCyl)
        addChildNode(zAlign)

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
