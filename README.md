# MRDropDown
[![Version](https://img.shields.io/badge/pod-v0.1.0-blue.svg)](https://cocoapods.org/pods/MRDropDown)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/mikeRozen/MRDropDown/blob/master/LICENSE)
[![Platform](https://img.shields.io/badge/pod-v0.1.1-blue.svg)](https://cocoapods.org/pods/MRDropDown)

## Getting Started
MRDropDown is fully customizable UI component based on Google API auto complete written in swift for IOS.
<img width="400" height="700" alt="screen shot 2018-09-19 at 19 43 57" src="https://user-images.githubusercontent.com/11506268/45768143-a95c5a00-bc44-11e8-8f51-9ef846263138.png"><img width="400" height="700" alt="screen shot 2018-09-19 at 19 44 47" src="https://user-images.githubusercontent.com/11506268/45768144-a95c5a00-bc44-11e8-849b-6f02e67f7102.png">

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements
IOS 9.0 or higher, IOS 10.0 for the Sample project

## Installation

MRDropDown is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'MRDropDown'
```

## Usage
You may use Interface Builder as well as write it in code.
If you use Interface builder please subclass `UITextfield` with `MRDropdown` 
You will also need  conform to `MRTextFieldDelegate` with the reqired method `addressDictionary` all the rest are optional
You may specify your properties as `Enum` array of `MRDropTextFieldOptions` or set the properties later on.
```objective-c
let textFieldOtions = [MRDropTextFieldOptions.textColor(UIColor.black),
MRDropTextFieldOptions.nibName(nib:UINib.init(nibName: "TableViewCell", bundle: nil), reuseIdentifier: "cell"),
MRDropTextFieldOptions.leftViewImage(UIImage.init(named: "locationImage")),
MRDropTextFieldOptions.tintColor(UIColor.green),
MRDropTextFieldOptions.tableviewHight(250.0),
MRDropTextFieldOptions.paddingFromTextField(20.0),
MRDropTextFieldOptions.selectAllOnTouch(true),
MRDropTextFieldOptions.language("en"),
MRDropTextFieldOptions.apiKey("****")]

textField.setupOptions(textFieldOtions)
textField.mrDelegate = self
```
You can see the rest of additional properties under  `MRDropTextFieldOptions`, just don't forget the google Api Key (`apiKey`)

### Inspirations
While studing Swift I thought it may be nice to help or contribute others

## Author

Michael Rozenblat

## License

MRDropDown is available under the MIT license. See the [LICENSE](https://github.com/mikeRozen/MRDropDown/blob/master/LICENSE) file for more info.
