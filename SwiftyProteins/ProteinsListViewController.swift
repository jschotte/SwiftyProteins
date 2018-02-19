//
//  ProteinsListViewController.swift
//  SwiftyCompanion
//
//  Created by Jeremy SCHOTTE on 2/12/18.
//  Copyright © 2018 Jeremy SCHOTTE. All rights reserved.
//

import UIKit


class ProteinsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate
{
    
    
    var ArrayProteins : [String] = []
    
    var filtered : [String] = []
    var isSearching = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        searchBar.delegate = self
        
        //navigationController?.interactivePopGestureRecognizer?.isEnabled = false

        
        let path = Bundle.main.path(forResource: "ligand", ofType: "txt")
        
        let filemgr = FileManager.default
        if (filemgr.fileExists(atPath: path!))
        {
            do
            {
                let fulltext = try String(contentsOfFile: path!, encoding: String.Encoding.utf8)
                
                ArrayProteins = fulltext.components(separatedBy: "\n") as [String]
            }
            catch (let err){
                displayError(e: err as NSError)
            }
        }
        
        searchBar.returnKeyType = UIReturnKeyType.done
    }
    
    @IBOutlet weak var proteins: UITableView!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if (isSearching)
        {
            return filtered.count
        }
        else
        {
            return ArrayProteins.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "protein")
        if (isSearching)
        {
            cell?.textLabel?.text = filtered[indexPath.row]
        }
        else
        {
            cell?.textLabel?.text = ArrayProteins[indexPath.row]
        }
        return cell!
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
    
        if (searchBar.text == nil || searchBar.text == "")
        {
            isSearching = false
            
            view.endEditing(true)
        }
        else
        {
            isSearching = true
            
            filtered = ArrayProteins.filter({$0.contains(searchText)})
            proteins.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath)
    {
        proteins.isUserInteractionEnabled = false
        print("select row")
        if (isSearching)
        {
            getProtein(lig: filtered[indexPath.row] as String);
        }
        else
        {
            getProtein(lig: ArrayProteins[indexPath.row] as String);
        }
    }
    
    func displayError(e: NSError)
    {
        let myalert = UIAlertController(title: "Error", message: NSError.description(), preferredStyle: UIAlertControllerStyle.alert)
        
        myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            print("Selected")
        })
        self.present(myalert, animated: true)
    }
    
    func getProtein(lig: String)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        DispatchQueue.global(qos: .userInitiated).async
        {
            let myURLString = "https://files.rcsb.org/ligands/view/\(lig)_ideal.pdb"
            guard let myURL = URL(string: myURLString) else
            {
                let myalert = UIAlertController(title: "Error", message: "url invalid", preferredStyle: UIAlertControllerStyle.alert)
                
                myalert.addAction(UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
                    print("Selected")
                })
                self.present(myalert, animated: true)
                return
            }
            
            do
            {
                let myHTMLString = try String(contentsOf: myURL, encoding: .ascii)
                DispatchQueue.main.async
                {
                    self.performSegue(withIdentifier: "showProtein", sender: (myHTMLString, lig))
                }
            }
            catch (let err){
                self.displayError(e: err as NSError)
            }
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false

        let c = sender as? (String, String)
        if segue.identifier == "showProtein"
        {
            if let vc = segue.destination as? ProteinViewController
            {
                proteins.isUserInteractionEnabled = true

                vc.title = c?.1
                vc.dataRaw = (c?.0)!

            }
        }
    }

}


