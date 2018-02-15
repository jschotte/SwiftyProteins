//
//  ViewController.swift
//  SwiftyCompanion
//
//  Created by Jeremy SCHOTTE on 2/12/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit
import LocalAuthentication

class ViewController: UIViewController {

    let context = LAContext()

    @IBOutlet weak var touchID: UIButton!
    override func viewDidLoad()
    {
        super.viewDidLoad()

        if (context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil) == false)
        {
            touchID.isHidden = true;
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func clickTouchId(_ sender: UIButton)
    {

        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: nil)
        {
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "You need to authentificate")
            {
                (success, error) in
                if success
                {
                    DispatchQueue.main.async
                    {
                        self.performSegue(withIdentifier: "authentificate", sender: self)
                    }
                }
                else
                {
                    let myalert = UIAlertController(title: "Error", message: "Authentification failed", preferredStyle: UIAlertControllerStyle.alert)
                    
                    myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                        print("Selected")
                    })
                    self.present(myalert, animated: true)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("SEGUE")
        if segue.identifier == "authentificate"
        {
            if segue.destination is ProteinsListViewController
            {
                
            }
        }
    }

}

