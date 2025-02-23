import Combine
import Foundation
import UIKit

struct ImageTemplate: Identifiable, Hashable {
    let id: String
    let template: CanvasLayers
    let isLoading: Bool
    let image: UIImage

    init(image: UIImage, template: CanvasLayers, isLoading: Bool) {
        self.template = template
        self.isLoading = isLoading
        self.image = image
        var hasher = Hasher()
        hasher.combine(template.hashValue)
        hasher.combine(image.hashValue)
        self.id = "\(hasher.finalize())"
    }

    init(template: CanvasLayers, segmentationResult: SegmentationResult) {
        let image: UIImage = if template.personLayer?.isCropped == true {
            segmentationResult.croppedResultImage
        } else {
            segmentationResult.resultImage
        }
        self.init(image: image, template: template, isLoading: false)
    }

    func withUpdatingLayer(atIndex index: Int, with kind: CanvasLayer.Kind) -> ImageTemplate {
        guard index >= 0 && index < template.layers.count else {
            return self
        }
        let newLayers = template.layers.enumerated().map { i, layer in
            if i == index {
                layer.copyOverriding(kind: kind)
            } else {
                layer
            }
        }
        return withUpdating(template: CanvasLayers(layers: newLayers))
    }

    func withUpdatingPersonLayerWith(isPlaceholder: Bool) -> ImageTemplate {
        let newLayers = template.layers.map { layer in
            if layer.type == .person {
                layer.copyOverriding(isPlaceholder: isPlaceholder)
            } else {
                layer
            }
        }
        return withUpdating(template: CanvasLayers(layers: newLayers))
    }

    func withUpdatingPersonsPreviousLayer(with kind: CanvasLayer.Kind, id: String? = nil) -> ImageTemplate {
        guard let index = (template.layers.firstIndex { $0.type == .person }) else {
            return self
        }
        let personPrevIndex = index - 1
        return withUpdatingLayer(atIndex: personPrevIndex, with: kind)
    }

    func withUpdating(layerType: LayerType, with kind: CanvasLayer.Kind, id: String? = nil) -> ImageTemplate {
        let newLayers = template.layers.map { layer in
            if layer.type == layerType {
                layer.copyOverriding(kind: kind)
            } else {
                layer
            }
        }

        return withUpdating(template: CanvasLayers(layers: newLayers))
    }

    func withUpdating(template newTemplate: CanvasLayers? = nil, isLoading newLoading: Bool? = nil) -> ImageTemplate {
        ImageTemplate(image: image, template: newTemplate ?? template, isLoading: newLoading ?? isLoading)
    }
}
