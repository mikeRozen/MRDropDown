# MRDropDown

[![CI Status](https://img.shields.io/travis/mike.rozen1@gmail.com/MRDropDown.svg?style=flat)](https://travis-ci.org/mike.rozen1@gmail.com/MRDropDown)
[![Version](https://img.shields.io/cocoapods/v/MRDropDown.svg?style=flat)](https://cocoapods.org/pods/MRDropDown)
[![License](https://img.shields.io/cocoapods/l/MRDropDown.svg?style=flat)](https://cocoapods.org/pods/MRDropDown)
[![Platform](https://img.shields.io/cocoapods/p/MRDropDown.svg?style=flat)](https://cocoapods.org/pods/MRDropDown)

## Getting Started
MRDropDown is fully customizable UI component based on Google API auto complete written in swift for IOS.

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

MRDropDown is available under the MIT license. See the LICENSE file for more info.
