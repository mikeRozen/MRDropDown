//
//  DNPDropTextField.swift
//  driveNpass
//
//  Created by Michael Rozenblat on 10/27/17.
//  Copyright © 2017 Michael Rozenblat. All rights reserved.
//

import UIKit
import Foundation

public enum MRDropTextFieldOptions {
    case textColor(UIColor)
    case tableViewBackgroundColor(UIColor)
    case tableViewSeperatorColor(UIColor)
    case tableviewHight(Float)
    case cellHeight(Float)
    case tableViewHeight(Float)
    case nibName(nib: UINib,reuseIdentifier: String)
    case className(classType: AnyClass,reuseIdentifier: String)
    case paddingFromTextField(Float)
    case showFading(Bool)
    case leftViewImage(UIImage?)
    case placeHolder(String)
    case textPadding(Float)
    case textFieldWidthSize(Float)
    case selectAllOnTouch(Bool)
    case language(String?)
    case font(UIFont?)
    case apiKey(String)
    case tintColor(UIColor?)
    case search(String?)
    case searchTimeDelay(TimeInterval)
    case name(String?)
    case bgViewEnable(Bool)
    case startSearchCharacterNumber(Int)
}

@objc public protocol MRTextFieldDelegate : NSObjectProtocol {
    @objc optional func textFieldCostumeShouldBeginEditing(_ textField: UITextField) -> Bool
    @objc optional func textFieldCostumeDidEndEditing(_ textField: UITextField)
    @objc optional func textFieldCostumeShouldChangeCharactersInRange(_ textField: UITextField, range: NSRange, replacementString:String) -> Bool
    @objc optional func tableView(tableView: UITableView, cellForRowAt indexPath: IndexPath ,cell: UITableViewCell, places: [Places]?) -> UITableViewCell
    @objc func addressDictionary(address: NSDictionary?)
    @objc optional func googleError(error: NSError?)
}

open class MRDropDown: UITextField {
    //UI
    var leftImage: UIImage?
    var textPadding: Float = 20.0
    var textFieldWidthSize: Float = 0.0
    var leftBtn: UIButton?
    weak open var mrDelegate: MRTextFieldDelegate?
    var rightIcon: UIImage?
    open var bgView: UIView?
    open var bgViewEnabled: Bool = true
    open var selectAllOnTouch: Bool = true
    
    //Controllers
    var tableViewController: UITableViewController?
    open var reuseIdentifier:String?
    open var nib: UINib?
    open var classType: AnyClass?
    open var tableViewHeight: Float = 250.0;
    open var cellHeight: Float = 50.0;
    open var paddigFromTextField: Float = 20.0
    
    //DATA
    var stringToSearch: String?
    var pastSearchResults = [String:[Dictionary<String, Any>]]()
    var places: [Places]? = [Places]()

    var data = [String]();
    
    //Additions
    var searchTimer: Timer?
    var searchTimeDelay: TimeInterval = 0.3
    open var apiKey = "*****"
    var startSerachCharcterNumber: Int = 2
    
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
        self.autocapitalizationType = .sentences;
        self.clearButtonMode = UITextFieldViewMode.whileEditing;
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.placeholder = "Enter your place"
        
    }
    
    open func setupOptions(_ options: [MRDropTextFieldOptions]?){
        if let optionsTextFld = options {
            for option in optionsTextFld {
                switch (option) {
                case let .textColor(value):
                    self.textColor = value
                    break;
                case let .leftViewImage(value):
                    guard let value = value else {return}
                    self.leftImage = value
                   // print("size of rect = \(NSStringFromCGRect(self.frame))")
                    let height = self.frame.height
                    let imageView = UIImageView(frame: CGRect(x: 0.0, y: 0.0, width: (height * 0.5), height: height))
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
                case let .font(value):
                    guard let value = value else {return}
                    self.font = value
                    break
                case let .tintColor(value):
                    guard let value = value else {return}
                    self.tintColor = value
                    break
                case let .tableViewHeight(value):
                    self.tableViewHeight = value
                    break
                case let .cellHeight(value):
                    self.cellHeight = value
                    break
                case let .paddingFromTextField(value):
                    self.paddigFromTextField = value
                    break
                case let .searchTimeDelay(value):
                    self.searchTimeDelay = value
                    break
                case let .nibName(value1,value2):
                    self.nib = value1
                    self.reuseIdentifier = value2
                    break
                case let .className(value1,value2):
                    self.classType = value1
                    self.reuseIdentifier = value2
                    break
                case let .bgViewEnable(value):
                    self.bgViewEnabled = value
                    break
                case let .startSearchCharacterNumber(value):
                    self.startSerachCharcterNumber = value
                    break
                case let .selectAllOnTouch(value):
                    self.selectAllOnTouch = value
                    break
                case let .apiKey(value):
                    self.apiKey = value
                    break
                default:
                    break
                }
            }
        }
    }
    
    func inputExists(){
        if (self.text?.count == 0 && self.isFirstResponder){
            
        }
    }
    
    //MARK - TableView UI
    func suggestDropDown(){
        if (tableViewController == nil && places?.count != 0){
            tableViewController = UITableViewController.init()
            rectForDropDown(withHeight: tableViewHeight)
            registerTableCell()
            tableViewController?.tableView.delegate = self
            tableViewController?.tableView.dataSource = self
           
            tableViewController?.tableView.layer.borderWidth = 1.0
            tableViewController?.tableView.layer.borderColor = UIColor.gray.cgColor
            tableViewController?.tableView.layer.cornerRadius = 5.0
            self.superview?.addSubview((tableViewController?.tableView)!)
            
            tableViewController?.tableView.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.tableViewController?.tableView.alpha = 1
            })
            makeBgView()
            self.superview?.bringSubview(toFront: self)
            self.superview?.bringSubview(toFront: (tableViewController?.tableView)!)
        }else{
            tableViewController?.tableView.reloadData()
        }
    }
    
    func registerTableCell(){
        if let nib = nib, let reuseIdentifier = reuseIdentifier{
            tableViewController?.tableView.register(nib, forCellReuseIdentifier: reuseIdentifier)
        }else if let classType = classType, let reusIdentifier = reuseIdentifier{
            tableViewController?.tableView.register(classType, forCellReuseIdentifier: reusIdentifier)
        }else{
            reuseIdentifier = "cell"
            tableViewController?.tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier!)
        }
    }
    
    func makeBgView(){
        if !bgViewEnabled{return}
        if bgView != nil {
           bgViewAdd()
        }
        
        guard let frame = self.superview?.frame else {return}
        bgView = UIView.init(frame: frame)
        bgView?.backgroundColor = UIColor.darkGray
        bgViewAdd()
        
        let recognizer = UITapGestureRecognizer.init(target: self, action: #selector(bgViewTapped))
        bgView?.addGestureRecognizer(recognizer)
        
    }
    
    func bgViewAdd() {
        bgView?.alpha = 0
        self.superview?.addSubview(bgView!)
        UIView.animate(withDuration: 0.25, animations: {
            self.bgView?.alpha = 0.4
        })
    }
    
    func bgViewTapped(){
         _ = resignFirstResponder()
        self.text = nil
    }
    
    func rectForDropDown(withHeight height: Float){
        var rect = self.frame
        rect.origin.y += self.frame.height + CGFloat(paddigFromTextField)
        rect.size.height = CGFloat(height)
        tableViewController?.tableView.frame = rect
    }
    
    
    //MARK - Padding
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += CGFloat(textPadding)
        return newBounds
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += CGFloat(textPadding)
        return newBounds
    }
    
    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        var newBounds = bounds
        newBounds.origin.x += CGFloat(textPadding)
        return newBounds
    }
    
    override open func setBaseWritingDirection(_ writingDirection: UITextWritingDirection, for range: UITextRange) {
//        if writingDirection == .leftToRight{
//            textPadding = abs(textPadding)
//
//        }
//        if (writingDirection == .rightToLeft){
//            textPadding = -abs(textPadding)
//        }
    }
//    override open func baseWritingDirection(for position: UITextPosition, in direction: UITextStorageDirection) -> UITextWritingDirection {
//        return .leftToRight
//    }
    
    
    //MARK: - Exit Methods
    override open func resignFirstResponder() -> Bool {
        exit()
        return super.resignFirstResponder()
    }
    
    func exit(){
        UIView.animate(withDuration: 0.25, animations: {
            self.tableViewController?.tableView.alpha = 0
            self.bgView?.alpha = 0
        }) { (Bool) in
            self.tableViewController?.tableView.removeSubviews()
            self.tableViewController = nil
            self.bgView?.removeFromSuperview()
            self.bgView = nil
        }
    }
    
    //MARK: Search Methods
    func executeSearch(){
        searchTimer?.invalidate()
        searchTimer = Timer.scheduledTimer(timeInterval: searchTimeDelay, target: self, selector: #selector(self.searchByString), userInfo: nil, repeats: false)
    }
    
    func searchByString(){
        guard let stringToSearch = stringToSearch else {return}
        
        if let value =  self.pastSearchResults[stringToSearch]{
            //We probably alreday made search for that word
            places = makeTableData(results: value)
            suggestDropDown()
        }else{
            googleSearch(completion: { (results: [Dictionary<String, Any>]?,error:NSError?) in
                guard let results = results, error == nil else {return}
                self.places = self.makeTableData(results: results)
                self.pastSearchResults[stringToSearch] = results
                DispatchQueue.main.async {self.suggestDropDown()}
            })
        }
    }
    
    func makeTableData(results: [Dictionary<String, Any>]?) -> [Places]?{
        guard let results = results else {return nil }
        let places = results.map({ (result: Dictionary<String, Any>) -> Places in
            let place = Places();
            place.title    = ((result["terms"] as? NSArray)?.firstObject as? Dictionary<String, Any>)?["value"] as? String
            place.subtitle = result["description"] as? String
            place.placeId  = result["place_id"] as? String
            return place
        })
        return places
    }
    
    //MARK: - Google API
    func googleSearch(completion: @escaping (_ results: [Dictionary<String, Any>]?,_ error:NSError?) -> Void){
        guard let stringToSearch = stringToSearch else {return}
        if (stringToSearch.isEmpty || stringToSearch.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty){return}
        //TODO: I think that kind of encoding won't cover all the case
        let urlString = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(stringToSearch)&types=geocode&language=\(language)&key=\(apiKey)"
        guard let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        guard let  url = URL.init(string: urlStringEncoded) else {return}
        dataTask?.cancel()
        dataTask = defaultSession.dataTask(with: url){ data, response, error in
            defer{self.dataTask = nil}
            if error != nil{return}
            guard let data = data else {return}
            
            do{
                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                let status = result?["status"] as? String
                if (status == "OK" || status == "ZERO_RESULTS"){
                    let predictions = result?["predictions"] as? [Dictionary<String, Any>]
                    completion(predictions,nil)
                }else{
                    let errorMsg = result?["error_message"] as? String
                    let error = self.googleErrorHandler(status: status, errorMsg: errorMsg)
                    completion(nil,error)
                }
            }catch let error as NSError{
                print("googleSearch parsing failed = \(error.localizedDescription)")
                let error = NSError.init(domain: "Internal Error Probably Parsing", code: 1, userInfo: nil)
                completion(nil,error)
            }
        }
        
        dataTask?.resume()
    }
    
    func googlePlaceDetails(place: Places?, completion: @escaping(_ results: [String:Any]?,_ error:NSError?) -> Void){
        guard let place = place,let placeId = place.placeId else {return}
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeId)&types=address&language=\(language)&key=\(apiKey)"
        guard let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {return}
        guard let url = URL.init(string: urlStringEncoded) else {return}
        let task = defaultSession.dataTask(with: url) { (data, response, error) in
            if error != nil {return}
            guard let data = data else {
                print("error fetching address =\(String(describing: error))")
                return
            }
            
            do{
                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any]
                let status = result?["status"] as? String
                print("result = \(result as NSDictionary?)")
                if (status == "OK" || status == "ZERO_RESULTS"){
                    let results = result?["result"] as? [String:Any]
                    completion(results,nil)
                }else{
                    print("status Fetching Address error = \(String(describing: status))")
                    let errorMsg = result?["error_message"] as? String
                    let error = self.googleErrorHandler(status: status, errorMsg: errorMsg)
                    completion(nil,error)
                }
            }catch let error as NSError{
                print("googleSearch parsing failed = \(error.localizedDescription)")
                let error = NSError.init(domain: "Internal Error Probably Parsing", code: 1, userInfo: nil)
                completion(nil,error)
            }
        }
        task.resume()
    }
    
    func googleErrorHandler(status: String?,errorMsg: String?) -> NSError?{
        guard let status = status else {return nil}
        var error: NSError?
        switch status {
        case "OVER_QUERY_LIMIT":
            error = NSError.init(domain: "OVER_QUERY_LIMIT", code: 1, userInfo: ["error_msg":errorMsg ?? ""])
            break
        case "REQUEST_DENIED":
            error = NSError.init(domain: "REQUEST_DENIED", code: 1, userInfo: ["error_msg":errorMsg ?? ""])
            break;
        case "INVALID_REQUEST":
            error = NSError.init(domain: "INVALID_REQUEST", code: 1, userInfo: ["error_msg":errorMsg ?? ""])
            break;
        case "UNKNOWN_ERROR":
            error = NSError.init(domain: "UNKNOWN_ERROR", code: 1, userInfo: ["error_msg":errorMsg ?? ""])
            break
        default:
            break;
        }
        
        if error != nil{
            mrDelegate?.googleError?(error: error)
        }
        return error
    }
    
    
    func userDidSelect(place: Places?){
        guard let selectedPlace = place else {return}
        googlePlaceDetails(place: selectedPlace) { (results, error) in
            guard let results = results else {return}
            guard let coordinate = ((results["geometry"] as? [String:Any])?["location"] as? [String:Any]) else {return}
            //print("coordinate = \(coordinate as NSDictionary)")
            
            let lat = coordinate["lat"] as? Double
            let lng = coordinate["lng"] as? Double
            guard let addressComponents = results["address_components"] as? Array<[String:Any]> else {return}
            var homeNumber: String?
            var streetName: String?
            var cityName: String?
            var country: String?
            var postalCode: String?
            
            for component in addressComponents{
                let type = (component["types"] as? Array<String>)?.first
                if type == nil {continue}
                if (type == "street_number"){
                    homeNumber = component["long_name"] as? String
                    continue
                }
                
                if (type == "route"){
                    streetName = component["long_name"] as? String
                    continue
                }
                
                if (type == "locality") || (type == "postal_town") || (type == "political") {
                    cityName = component["long_name"] as? String
                    continue
                }
                
                if (cityName == nil && type == "administrative_area_level_1"){
                    cityName = component["long_name"] as? String;
                    continue
                }
                
                if (type == "country"){
                    country = component["long_name"] as? String;
                    continue
                }
                
                if (type == "postal_code"){
                    postalCode = component["long_name"] as? String;
                    continue
                }
            }
            
            let addressDictionary: [String:Any?] = ["homeNumber": homeNumber,"streetName": streetName,"cityName": cityName,"country": country,"postalCode": postalCode,"latitude": lat,"longitude":lng,"addressString": place?.subtitle]
            
            self.mrDelegate?.addressDictionary(address: (addressDictionary as NSDictionary))
            
        }
    }
}

open class  Places: NSObject {
    open var title: String?
    open var subtitle: String?
    open var placeId: String?
}

//MARK: - Extensions
extension MRDropDown: UITextFieldDelegate{
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool{
        return mrDelegate?.textFieldCostumeShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        if (selectAllOnTouch){
            self.selectAll(nil)
        }
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField){
        mrDelegate?.textFieldCostumeDidEndEditing?(textField)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if let stringToSearch = self.text{
            self.stringToSearch = (stringToSearch + string).trimmingCharacters(in: .whitespacesAndNewlines)
            let numberOfCharacters = self.stringToSearch?.count ?? 0
            if numberOfCharacters > startSerachCharcterNumber {
                //self.stringToSearch = self.stringToSearch?.replacingOccurrences(of: " ", with: "+")
                executeSearch()
            }
        }
        return mrDelegate?.textFieldCostumeShouldChangeCharactersInRange?(textField, range: range, replacementString: string) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        exit()
        return  true;
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        exit()
        return true
    }
}

extension MRDropDown: UITableViewDelegate,UITableViewDataSource{
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return (places?.count ?? 0)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        var cell: UITableViewCell
        
        if (mrDelegate != nil && (mrDelegate?.responds(to: #selector(mrDelegate?.tableView(tableView:cellForRowAt:cell:places:))))!){
            cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier!, for: indexPath)
            cell = (mrDelegate?.tableView?(tableView: tableView, cellForRowAt: indexPath, cell: cell,places: places))!
        }else{
            cell = UITableViewCell(style: .subtitle,
                                   reuseIdentifier: reuseIdentifier)
            cell.textLabel?.text = (places?[indexPath.row])?.title
            cell.detailTextLabel?.text = (places?[indexPath.row])?.subtitle
        }
        return cell
    }
    
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return CGFloat(cellHeight);
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        guard let place = places?[indexPath.row] else {return}
        userDidSelect(place: place)
        self.text = place.subtitle
        _ = resignFirstResponder()
    }
}


