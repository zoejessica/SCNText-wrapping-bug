//
//  VirtualTextObject.swift
//  ARKitExample
//
//  Created by Zoë Smith on 8/21/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import SceneKit
import UIKit

struct VirtualTextObjectDefinition: Equatable {
    let text: String
    let fontname: String
    let size: CGFloat
    let extrusionratio: CGFloat
    let isWrapped: Bool
    
    var displayName: String { return String(text.prefix(50)) }
    var thumbImage: UIImage { return  UIImage(named: "letter")! }
    
    static func ==(lhs: VirtualTextObjectDefinition, rhs: VirtualTextObjectDefinition) -> Bool {
        return lhs.text == rhs.text &&
            lhs.fontname == rhs.fontname &&
        lhs.size == rhs.size &&
        lhs.extrusionratio == rhs.extrusionratio &&
        lhs.isWrapped == rhs.isWrapped
    }
}

class VirtualObject : SCNNode {
    
    init(definition: VirtualTextObjectDefinition) {
        self.definition = definition
        super.init()
        
        let extrudedText = SCNText(string: definition.text, extrusionDepth: 0.1)
        extrudedText.font = UIFont(name: definition.fontname, size: 0.2)!
        
        // alignmentMode is currently broken on iOS, but works on the Mac. This is visible when doing multi line text. Refer to the documentation as to why containerFrame is needed.
        extrudedText.containerFrame = CGRect(origin: .zero, size: CGSize(width: 1.0, height: 5.0))
        extrudedText.truncationMode = kCATruncationNone
        extrudedText.isWrapped = definition.isWrapped
        extrudedText.alignmentMode = kCAAlignmentLeft
        
        
        let material = SCNMaterial.material(named: "rustediron-streaks")
        extrudedText.materials = [material]
        geometry = extrudedText
        
        // Update pivot of object to its center
        // https://stackoverflow.com/questions/44828764/arkit-placing-an-scntext-at-a-particular-point-in-front-of-the-camera
        let (min, max) = boundingBox
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let definition: VirtualTextObjectDefinition
    
    // Use average of recent virtual object distances to avoid rapid changes in object scale.
    var recentVirtualObjectDistances = [Float]()
    
}

extension VirtualObject {
    
    static func isNodePartOfVirtualObject(_ node: SCNNode) -> VirtualObject? {
        if let virtualObjectRoot = node as? VirtualObject {
            return virtualObjectRoot
        }
        
        if node.parent != nil {
            return isNodePartOfVirtualObject(node.parent!)
        }
        
        return nil
    }
    
}
