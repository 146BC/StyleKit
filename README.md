![alt text](https://i.imgur.com/IqDIU4q.png "StyleKit - A powerful & easy to use styling framework written in Swift")

[![Build Status](https://travis-ci.org/146BC/StyleKit.svg?branch=develop)](https://travis-ci.org/146BC/StyleKit) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

StyleKit is a microframework that enables you to style your applications using a simple JSON file. Behind the scenes, StyleKit uses [UIAppearance](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAppearance_Protocol/) and some selector magic to apply the styles. You can also customize the parser for greater flexibility.


### How does it work?

#### Create a JSON file in the following format

```js
{
	"@headingFont": "HelveticaNeue-Bold:30.0",
	"UILabel": {
		"font": "@headingFont",
		"backgroundColor": "#000FFF"
	},
	"StyleKitDemo.SKView": {
		"StyleKitDemo.SKLabel": {
			"font": "HelveticaNeue-Bold:20.0",
			"backgroundColor": "#FFF000",
			"color": "#fff"
		},
		"StyleKitDemo.SKButton": {
			"font": "HelveticaNeue-Light:20.0",
			"titleColor:normal": "#FFFFFF",
			"titleColor:highlighted": "#000000"
		}
	},
	"StyleKitDemo.SKNavigationBar": {
		"titleTextAttributes": {
			"NSColor": "#000FFF",
			"NSFont": "@headingFont"
		}
	},
	"StyleKitDemo.SKTextField": {
		"font": "HelveticaNeue-Light:20.0",
		"textColor": "#000FFF"
	}
}
```
#### Load JSON file

*AppDelegate.swift*

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    if let styleFile = Bundle.main.url(forResource: "style", withExtension: "json") {
        StyleKit(fileUrl: styleFile)?.apply()
    }
    
    return true
}
```

On application launch the JSON file will be loaded and the styles applied.


### The JSON file structure

Each object inside the JSON file should contain the name of the UIView as a key and the object inside should either contain the properties/functions that need to be set/called or another UIView, this will give you the ability to apply styles on views when contained in other views, an example of this would be the following.

```js
{
	"UIButton": {
		"font": "HelveticaNeue-Bold:20.0"
	},
	"MyApp.LoginView": {
		"UIButton": {
			"font": "HelveticaNeue-Light:25.0"
		}
	}
}
```

This would apply HelveticaNeue-Bold with size 20 to all the UIButtons except the ones contained inside the LoginView class in your app.

Custom classes must be namespaced by the name of the module they are contained in. e.g. `StyleKitDemo.SKTextField`

### Aliases

```js
{
    "@mainFont": "HelveticaNeue-Bold:20.0",
    "@primaryColor": "#000FFF",
    "UIButton": {
        "font": "@mainFont"
    },
    "MyApp.LoginView": {
        "UIButton": {
            "font": "HelveticaNeue-Light:25.0",
            "titleColor:normal": "@primaryColor"
        }
    }
}
```

### Bring Your Own Parser

StyleKit's initialiser supports passing a custom parser which should conform to the `StyleParsable` protocol.

*Default Parser*

```swift
class StyleParser: StyleParsable {

    func getStyle(forName name: String, value: AnyObject) -> AnyObject { 
        if let value = value as? String {
            if let font = FontHelper.parseFont(value) {
                return font
            } else if let color = ColorHelper.parseColor(value) {
                return color
            }
        }
        return value
    }
}
```

*AppDelegate.swift*

```swift
func application(_ application: UIApplication,
                 didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    if let styleFile = Bundle.main.url(forResource: "style", withExtension: "json") {
        StyleKit(fileUrl: styleFile, styleParser: StyleParser())?.apply()
    }
    
    return true
}
```

### Logging

By default, StyleKit will log any errors to the console. To customise the level of logging, you can pass a logLevel parameter as follows:

```swift
StyleKit(fileUrl: styleFile, logLevel: .debug)?.apply()
```

The levels of logging are:

* ```.debug```
* ```.error``` (This is the default log level)
* ```.severe```
* ```.none```


### How to install?

#### Carthage

##### Swift 3

```ogdl
github "146BC/StyleKit" ~> 0.6
```
##### Swift 4

```ogdl
github "146BC/StyleKit" ~> 0.7
```

#### CocoaPods

Add the 146BC Source

```ruby
source 'https://github.com/146BC/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

##### Swift 3

```ruby
pod 'StyleKit', '~> 0.6'
```

##### Swift 4

```ruby
pod 'StyleKit', '~> 0.7'
```