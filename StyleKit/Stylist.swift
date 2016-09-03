import Foundation

class Stylist {
    
    typealias Style = [String:AnyObject]
    typealias setValueForControlState = @convention(c) (AnyObject, Selector, AnyObject, UInt) -> Void
    
    let data: Style
    let styleParser: StyleParsable
    var currentComponent: AnyClass?
    var viewStack = [AnyClass]()
    
    init(data: Style, styleParser: StyleParsable?) {
        self.styleParser = styleParser ?? StyleParser()
        self.data = data
    }
    
    func apply() {
        SKTryCatch.tryBlock( {
            self.validateAndApply(self.data)
        }, catchBlock: { exception in
            SKLogger.severe("There was an error while applying styles: \(exception)")
        }, finallyBlock: nil)
    }
    
    private func validateAndApply(data: Style) {
        
        for (key, value) in data {
            if let value = value as? Style where NSClassFromString(key) != nil {
                if selectCurrentComponent(key) {
                    viewStack.append(self.currentComponent!)
                }
                validateAndApply(value)
                viewStack.popLast()
                if viewStack.count > 0 {
                    self.currentComponent = viewStack.last
                }
            }
            else {
                SKTryCatch.tryBlock( {
                    if let currentComponent = self.currentComponent {
                        self.applyStyle(key, object: value, currentComponent: currentComponent)
                    } else {
                        SKLogger.error("Style \(value) not applied on \(key) for \(self.currentComponent.debugDescription)")
                    }
                }, catchBlock: { exception in
                    SKLogger.error("Style \(value) not applied on \(key) for \(self.currentComponent.debugDescription) Error \(exception)")
                }, finallyBlock: nil)
            }
        }
    }
    
    private func selectCurrentComponent(name: String) -> Bool {
        
        SKLogger.debug("Switching to: \(name)")
        
        guard let currentComponent = NSClassFromString(name) else {
            SKLogger.debug("Component \(name) cannot be selected")
            return false
        }
        self.currentComponent = currentComponent
        return true
    }
    
    private func applyStyle(name: String, object: AnyObject, currentComponent: AnyClass) {
        
        var selectorName = name
        let nameState = name.componentsSeparatedByString(":")
        var state: AnyObject?
        if nameState.count == 2 {
            selectorName = "\(nameState.first!):forState"
            state = ControlStateHelper.parseControlState(nameState.last!)
        } else {
            state = nil
        }
        
        SKLogger.debug("Applying: \(selectorName) on level \(self.viewStack.count)")
        if let styles = object as? Stylist.Style {
            var stylesToApply = Stylist.Style()
            for (style, value) in styles {
                stylesToApply[style] = styleParser.getStyle(forName: name, value: value)
            }
            callAppearanceSelector(selectorName, valueOne: stylesToApply, valueTwo: state)
        } else {
            let value = styleParser.getStyle(forName: name, value: object)
            callAppearanceSelector(selectorName, valueOne: value, valueTwo: state)
        }
        
    }
    
    private func callAppearanceSelector(selector: String, valueOne: AnyObject?, valueTwo: AnyObject?) {
        
        let modifiedSelector = "set\(selector.capitalizeFirstLetter()):"
        
        var viewStack = self.viewStack
        viewStack.popLast()
        
        let isViewStackRelevant = viewStack.count > 0
        viewStack = viewStack.reverse()
        
        if valueOne == nil && valueTwo == nil {
            if isViewStackRelevant {
                if #available(iOS 9.0, *) {
                    self.currentComponent?.appearanceWhenContainedInInstancesOfClasses(viewStack).performSelector(Selector(modifiedSelector))
                } else {
                    self.currentComponent?.styleKitAppearanceWhenContainedWithin(viewStack).performSelector(Selector(modifiedSelector))
                }
            } else {
                self.currentComponent?.appearance().performSelector(Selector(modifiedSelector))
            }
        } else if valueOne != nil && valueTwo != nil {
            if isViewStackRelevant {
                if #available(iOS 9.0, *) {
                    let methodSignature = self.currentComponent!.appearanceWhenContainedInInstancesOfClasses(viewStack).methodForSelector(Selector(modifiedSelector))
                    let callback = unsafeBitCast(methodSignature, setValueForControlState.self)
                    callback(self.currentComponent!.appearanceWhenContainedInInstancesOfClasses(viewStack), Selector(modifiedSelector), valueOne!, valueTwo as! UInt)
                } else {
                    let methodSignature = self.currentComponent!.styleKitAppearanceWhenContainedWithin(viewStack).methodForSelector(Selector(modifiedSelector))
                    let callback = unsafeBitCast(methodSignature, setValueForControlState.self)
                    callback(self.currentComponent!.styleKitAppearanceWhenContainedWithin(viewStack), Selector(modifiedSelector), valueOne!, valueTwo as! UInt)
                }
            } else {
                let methodSignature = self.currentComponent!.appearance().methodForSelector(Selector(modifiedSelector))
                let callback = unsafeBitCast(methodSignature, setValueForControlState.self)
                callback(self.currentComponent!.appearance(), Selector(modifiedSelector), valueOne!, valueTwo as! UInt)
            }
        } else if valueOne != nil {
            if isViewStackRelevant {
                if #available(iOS 9.0, *) {
                    self.currentComponent?.appearanceWhenContainedInInstancesOfClasses(viewStack).performSelector(Selector(modifiedSelector), withObject: valueOne!)
                } else {
                    self.currentComponent?.styleKitAppearanceWhenContainedWithin(viewStack).performSelector(Selector(modifiedSelector), withObject: valueOne!)
                }
            } else {
                self.currentComponent?.appearance().performSelector(Selector(modifiedSelector), withObject: valueOne!)
            }
        }
    }
    
}