# StyleKit
### A powerful easy to use styling framework written in Swift.

StyleKit uses the appearance proxy of UIViews to style iOS applications from JSON.

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

That's it, on application launch the JSON file will be loaded and the styles applied.


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

###Bring Your Own Parser

StyleKit's initialiser supports sending in your own parser, the parser needs to support the `StyleParsable` protocol.

*Default Parser*

```
class StyleParser: StyleParsable {
    
    func getStyle(forName name: String, value: String) -> AnyObject? {
        
        if let font = FontHelper().parseFont(value) {
            return font
        } else if let color = ColorHelper().parseColor(value) {
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

Carthage

```
github "146BC/StyleKit" ~> 0.1
```

CocoaPods

```
Coming Soon
```