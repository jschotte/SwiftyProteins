//
//  ProteinsListViewController.swift
//  SwiftyCompanion
//
//  Created by Jeremy SCHOTTE on 2/12/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit

class ProteinsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    
    
    var ArrayProteins : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = Bundle.main.path(forResource: "ligands", ofType: "txt")
        
        let filemgr = FileManager.default
        if (filemgr.fileExists(atPath: path!))
        {
            do
            {
                let fulltext = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
                
                ArrayProteins = fulltext.components(separatedBy: "\n") as [String]
            }
            catch let error as NSError {
                print("Error: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArrayProteins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if (indexPath.row == 0)
         {
         let cell = tableView.dequeueReusableCell(withIdentifier: "search") as? SearchTableViewCell
         return cell!
         }
         else
         {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protein")
        cell?.textLabel?.text = ArrayProteins[indexPath.row - 1]
        return cell!
        }
    }
    
}


