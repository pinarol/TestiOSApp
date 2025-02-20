//
//  File.swift
//  CanvasEditor
//
//  Created by Pinar Olguc on 20.02.2025.
//

import Foundation

extension Array {
    
    func circularElement(at index: Int) -> Element {
        let i = ((index % count) + count) % count
        return self[i]
    }
}
