//
//  TransformSchemaEntityTreeToList.swift
//  i2Elevator
//
//  Created by János Kukoda on 05/03/2024.
//

func transformSchemaEntityTreeToList(
    schemaItemId: String?,
    userDTO: UserDTO?,
    shareState: SharedState,
    transformationId: String?,
    indentation: Int,
    numOf1SWalkedBy: Int,
    reference: [[String]]
) -> [IndentedSchemaItem] {
    guard let schemaItemId = schemaItemId, 
            let userDTO = userDTO, let transformationId = transformationId else
    {
        return []
    }
    guard let schemaItem = userDTO.teams?["response"]?.transformations[transformationId]?.schemaItems[schemaItemId] else {
        return []
    }
    var ret: [IndentedSchemaItem] = []
    for (k, v) in schemaItem.children.sorted(by: {
        let a = $0.value.rowNum ?? 1 // TODO: Make default 1
        let b = $1.value.rowNum ?? 1
        return a < b
    }) {
        guard let child = userDTO.teams?["response"]?.transformations[transformationId]?.schemaItems[k] else {
            continue
        }
        var newReference: [[String]] = reference
        newReference[newReference.count - 1].append(k)
        var rightText: String? = nil
        if let ll = shareState.runTransformationReturn,
           let internalRepresentation = ll["internalRepresentation"]//,
        {
            var container = internalRepresentation
            for i in 0 ..< reference.count {
                let subReference = reference[i]
                for j in 0 ..< subReference.count {
                    let subSubReference = subReference[j]
                    if i == 0, j == 0, let _c = container as? [String: Any] {
                        container = _c.values.first
                    }
                    if let _container = container as? [Any]
                    {
                        container = _container[0]
                    }
                    if let _container = container as? [String: Any],
                       let nextContainer = _container[subSubReference]
                    {
                        container = nextContainer
                    }
                }
                if subReference.count == 0, let _c = container as? [String: Any] { //i == 0,
                    container = _c.values.first
                } else if subReference.count == 0, let _c = container as? [Any], _c.count > 1 {
                    container = _c[0]
                }
            }
            if let _container = container as? [String: Any],
               let nextContainer = _container[k] as? String
            {
                rightText = String(nextContainer.prefix(10))
            }
        }
        ret.append(IndentedSchemaItem(indentation: indentation, numOfChildren: child.children.count, schemaItemId: k, parentSchemaItemId: schemaItemId, rangeMax: v.rangeMax, numOf1SWalkedBy: numOf1SWalkedBy, reference: newReference, rightText: rightText))
        if v.rangeMax == "S" {
            newReference.append([])
        }
        let a = transformSchemaEntityTreeToList(
            schemaItemId: k,
            userDTO: userDTO,
            shareState: shareState,
            transformationId: transformationId,
            indentation: indentation+1, 
            numOf1SWalkedBy: v.rangeMax == "S" ? numOf1SWalkedBy + 1 : numOf1SWalkedBy, 
            reference: newReference
        )
        ret += a
    }
    return ret
}
