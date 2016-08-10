![alt text](https://i.imgur.com/IqDIU4q.png "StyleKit - A powerful & easy to use styling framework written in Swift")

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

StyleKit is a microframework that enables you to style your applications using a simple JSON file. Behind the scenes, StyleKit uses [UIAppearance](https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIAppearance_Protocol/) and some selector magic to apply the styles. You can also customize the parser for greater flexibility. 


###How does it work?

####Create a JSON file in the following format

```
{
    "UILabel": {
        "font": "HelveticaNeue-Bold:30.0",
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
            "titleColor:normal":"#FFFFFF",
            "titleColor:highlighted":"#000000"
        }
    },
    "StyleKitDemo.SKNavigationBar": {
        "titleTextAttributes": {
            "NSColor": "#000FFF",
            "NSFont": "HelveticaNeue-Bold:30.0"
        }
    },
    "StyleKitDemo.SKTextField": {
        "font": "HelveticaNeue-Light:20.0",
        "textColor": "#000FFF"
    }
}
```
####Load JSON file

*AppDelegate.swift*

```
func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
	let styleFile = NSBundle.mainBundle().URLForResource("style", withExtension: "json")!
        
	StyleKit(fileUrl: styleFile)?.apply()
        
	return true
}
```

On application launch the JSON file will be loaded and the styles applied.


###The JSON file structure

Each object inside the JSON file should contain the name of the UIView as a key and the object inside should either contain the properties/functions that need to be set/called or another UIView, this will give you the ability to apply styles on views when contained in other views, an example of this would be the following.

```
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

###Bring Your Own Parser

StyleKit's initialiser supports passing a custom parser which should conform to the `StyleParsable` protocol.

*Default Parser*

```
class StyleParser: StyleParsable {
    
    func getStyle(forName name: String, value: String) -> AnyObject? {
        
        if let font = FontHelper.parseFont(value) {
            return font
        } else if let color = ColorHelper.parseColor(value) {
            return color
        } else {
            return value
        }
        
    }
    
}
```

*AppDelegate.swift*

```
func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
	let styleFile = NSBundle.mainBundle().URLForResource("style", withExtension: "json")!
        
	StyleKit(fileUrl: styleFile, styleParser: StyleParser())?.apply()
        
	return true
}
```

###How to install?

####Carthage

```
github "146BC/StyleKit" ~> 0.1
```

####CocoaPods

Add the 146BC Source

```
source 'https://github.com/146BC/Specs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

```
pod 'StyleKit', '~> 0.1'
```