//
//  DNPDropTextField.swift
//  driveNpass
//
//  Created by Michael Rozenblat on 10/27/17.
//  Copyright © 2017 Michael Rozenblat. All rights reserved.
//

import UIKit

public enum MRDropTextFieldOptions {
    case textColor(UIColor)
    case tableViewBackgroundColor(UIColor)
    case tableViewSeperatorColor(UIColor)
    case tableviewHight(Float)
    case paddingTableViewTextField(Float)
    case cellTitleFont(UIFont)
    case cellSubTitleFont(UIFont)
    case cellClass(String)
    case cellNibName(String)
    case cellBackground(UIColor)
    case showFading(Bool)
    case leftViewImage(UIImage)
    case placeHolder(String)
    case textPadding(CGFloat)
    case textFieldWidthSize(CGFloat)
    case inputView(UIImage?)
    case language(String?)
}

@objc public protocol MRTextFieldDelegate : NSObjectProtocol {
    @objc optional func textFieldCostumeShouldBeginEditing(_ textField: UITextField) -> Bool;
    @objc optional func textFieldCostumeDidEndEditing(_ textField: UITextField);
    @objc optional func textFieldCostumeShouldChangeCharactersInRange(_ textField: UITextField, range: NSRange, replacementString:String) -> Bool;
}

open class MRDropDown: UITextField {
    //UI
    var leftImage: UIImage?
    var textPadding: CGFloat = 35.0
    var textFieldWidthSize: CGFloat = 0.0
    var leftBtn: UIButton?
    weak open var mrDelegate: MRTextFieldDelegate?
    var rightIcon: UIImage?
    
    //Controllers
    var tableViewController: UITableViewController?
    let reuseIdentifier = "cell"
    
    //DATA
    var stringToSearch: String?
    var localSearchQueries  = [String]();
    var pastSearchWords = [String]();
    var pastSearchResults = [String:[Dictionary<String, Any>]]();
    var data = [String]();
    
    //Additions
    var searchTimer: Timer?
    let apiKey = "AIzaSyCd1AWTjZ7W1ZfZD3CjzHmhjDUvQ5aDpJU"
    
    //Connectivity
    lazy var  defaultSession = URLSession(configuration: .default)
    var dataTask: URLSessionDataTask?
    
    //properties
    var language = "en"
    
    
    required  public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    convenience public init(frame: CGRect,options: [MRDropTextFieldOptions]?) {
        self.init(frame: frame)
        self.setup()
        self.setupOptions(options)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setup(){
        self.delegate = self
        //self.addTarget(self, action: #selector(textFieldTyping),for: .editingChanged)
        //self.font = DNPStyles.samsungRegularSize(17.0)
        //self.tintColor = DNPStyles.brandColor()
        self.autocapitalizationType = .sentences;
    }
    
    func setupOptions(_ options: [MRDropTextFieldOptions]?){
        if let optionsTextFld = options {
            for option in optionsTextFld {
                switch (option) {
                case let .textColor(value):
                    self.textColor = value
                    break;
                case let .leftViewImage(value):
                    self.leftImage = value
                    //TODO: We need to decide on image size
                    let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0))
                    imageView.image = value
                    imageView.contentMode = .center
                    self.leftViewMode = .always
                    self.leftView = imageView
                    break
                case let .placeHolder(value):
                    self.placeholder = value
                    break
                case let .textPadding(value):
                    self.textPadding = value
                    break
                case let .textFieldWidthSize(value):
                    textFieldWidthSize = value
                    break
                case let .language(value):
                    guard let value = value else {return}
                    self.language = value
                    break
                default:
                    break
                }
            }
        }
    }
    
    func inputExists(){
        if (self.text?.characters.count == 0 && self.isFirstResponder){
            
        }
    }
    
    func suggestDropDown(){
        if (tableViewController == nil && data.count != 0 ){
            tableViewController = UITableViewController.init()
            //TODO: Fade in Gesture recognizer
            //TODO: we need to check if any class/nib was provided for registration
            tableViewController?.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
            tableViewController?.tableView.delegate = self
            tableViewController?.tableView.dataSource = self
            if let tableView = tableViewController?.tableView{
                self.superview?.addSubview(tableView)
            }
            tableViewController?.tableView.alpha = 0
            
            UIView.animate(withDuration: 0.25, animations: {
                self.tableViewController?.tableView.alpha = 1
            })
        }else{
            tableViewController?.tableView.reloadData()
        }
    }
    
    func rectForDropDown(_with height: Float ){
        var rect = self.frame
        rect.origin.y += self.frame.height
        //TODO:add pading between textfield and tableview
        rect.size.height = CGFloat(height)
        tableViewController?.tableView.frame = rect
    }
    
    override open func resignFirstResponder() -> Bool {
        exit()
        return super.resignFirstResponder()
    }
    
    func exit(){
        UIView.animate(withDuration: 0.25, animations: {
            self.tableViewController?.tableView.alpha = 0
        }) { (Bool) in
            self.tableViewController?.tableView.removeSubviews()
            self.tableViewController = nil
        }
    }
    
    func executeSearch(){
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.searchByString), userInfo: nil, repeats: false)
        
    }
    
    func searchByString(){
        if let stringToSearch = stringToSearch{
            if (!pastSearchWords.contains(stringToSearch)){
                self.pastSearchWords.append(stringToSearch)
                googleSearch(completion: { (results: [Dictionary<String, Any>]?,error:NSError?) in
                    
                    // var places = results.map({ (dict: [String : Any]) -> DNPAddress in
                    //         let address = DNPAddress.init();
                    
                    //         return address
                    // })
                    guard let results = results, error == nil else {
                        print("error=\(error)")
                        return
                    }
                    self.pastSearchResults[stringToSearch] = results
                    
                })
                
            }else{
                
            }
        }
    }
    
    //TODO: maybe I should make it throwable
    func googleSearch(completion: @escaping (_ results: [Dictionary<String, Any>]?,_ error:NSError?) -> Void){
        guard let stringToSearch = stringToSearch else {
            return
        }
        
        if (stringToSearch.isEmpty || stringToSearch.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty){
            return
        }
        
        //TODO: we may improve the query by seeting current location and radius
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(stringToSearch)&types=geocode&language=\(language)&key=\(apiKey)"
        
        guard let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else{
            return
        }
        
        let url = URL.init(fileURLWithPath: urlStringEncoded)
        
        dataTask?.cancel()
        dataTask = defaultSession.dataTask(with: url){ data, response, error in
            defer{self.dataTask = nil}
            guard let data = data, error == nil else {
                print("error=\(String(describing: error))")
                return
            }
            
            do{
                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                let status = result?["status"] as? String
                if (status == "OK" || status == "ZERO_RESULTS"){
                    let predictions = result?["predictions"] as? [Dictionary<String, Any>]
                    completion(predictions!,nil)
                }else{
                    //Some Othere error happened
                    print("status error = \(String(describing: status))")
                    let error = NSError.init(domain: "Google Autocomplete Error", code: 1, userInfo: nil)
                    completion(nil,error)
                }
            }catch let error as NSError{
                print("googleSearch parsing failed = \(error.localizedDescription)")
                let error = NSError.init(domain: "Internal Error Probably Parsing", code: 1, userInfo: nil)
                completion(nil,error)
            }
        }
    }
    
    func makeTableData(results: [Dictionary<String, Any>]?){
        guard let results = results else {return}
        var places = results.map({ (result: Dictionary<String, Any>) -> Dictionary<String, Any> in
            
            let title = ((result["terms"] as? NSArray)?.firstObject as? Dictionary<String, Any>)?["value"]
            let subtitle = result["description"]
            let placeID = result["place_id"]
            return ["title":title ?? "","subtitle":subtitle ?? "","placeID":placeID]
        })
        
        
    }
    
}

extension MRDropDown: UITextFieldDelegate{
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return mrDelegate?.textFieldCostumeShouldBeginEditing?(textField) ?? false
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField){
        mrDelegate?.textFieldCostumeDidEndEditing?(textField)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if let stringToSearch = self.text{
            self.stringToSearch = stringToSearch.trimmingCharacters(in: .whitespacesAndNewlines)
            let numberOfCharacters = self.stringToSearch?.characters.count ?? 0
            if numberOfCharacters > 1 {
                //self.stringToSearch = self.stringToSearch?.replacingOccurrences(of: " ", with: "+")
                executeSearch()
            }
        }
        _ = mrDelegate?.textFieldCostumeShouldChangeCharactersInRange?(textField, range: range, replacementString: string)
        return true
    }
    
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        exit()
        return  true;
    }
}

extension MRDropDown: UITableViewDelegate,UITableViewDataSource{
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath);
        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 50.0;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
    }
}


