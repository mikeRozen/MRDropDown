//
//  ViewController.swift
//  MRDropDown
//
//  Created by mike.rozen1@gmail.com on 09/08/2018.
//  Copyright (c) 2018 mike.rozen1@gmail.com. All rights reserved.
//

import UIKit
import MRDropDown

class ViewController: UIViewController {
    
    @IBOutlet weak var textField: MRDropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }

    func setup(){
        
        let textFieldOtions = [MRDropTextFieldOptions.textColor(UIColor.black),
                               MRDropTextFieldOptions.nibName(nib:UINib.init(nibName: "TableViewCell", bundle: nil), reuseIdentifier: "cell"),
                               MRDropTextFieldOptions.leftViewImage(UIImage.init(named: "locationImage")),
                               MRDropTextFieldOptions.tintColor(UIColor.green),
                               MRDropTextFieldOptions.tableviewHight(250.0),
                               MRDropTextFieldOptions.paddingFromTextField(20.0),
                               MRDropTextFieldOptions.selectAllOnTouch(true),
                               MRDropTextFieldOptions.language("en"),
                               MRDropTextFieldOptions.apiKey("*****")]
        
        textField.setupOptions(textFieldOtions)
        textField.mrDelegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ViewController: MRTextFieldDelegate {
    func tableView(tableView: UITableView, cellForRowAt indexPath: IndexPath ,cell: UITableViewCell,places: [Places]?) -> UITableViewCell{
        guard let places = places else {return cell}
        (cell as? TableViewCell)?.title.text = (places[indexPath.row]).title
        (cell as? TableViewCell)?.subtitle.text = (places[indexPath.row]).subtitle
        return cell
    }
    
    func googleError(error: NSError?){
        guard let error = error else {return}
        DispatchQueue.main.async {
            let title = error.domain
            let message = error.userInfo["error_msg"] as? String
            let alertController = UIAlertController(title: title,message:message, preferredStyle: UIAlertControllerStyle.actionSheet)
            let okAction = UIAlertAction(title:"OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func addressDictionary(address: NSDictionary?){
        guard  let address = address else {return}
        print("address = \(address)")
    }
}


