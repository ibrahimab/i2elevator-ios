//
//  TransformSchemaEntityTreeToList.swift
//  i2Elevator
//
//  Created by János Kukoda on 05/03/2024.
//

func transformSchemaEntityTreeToList(
    schemaItemId: String?,
    userDTO: UserDTO?,
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
    for (k, v) in schemaItem.children.sorted(by: { $0.key < $1.key }) {
        guard let child = userDTO.teams?["response"]?.transformations[transformationId]?.schemaItems[k] else {
            continue
        }
        var newReference: [[String]] = reference
        newReference[newReference.count - 1].append(k)
        ret.append(IndentedSchemaItem(indentation: indentation, numOfChildren: child.children.count, schemaItemId: k, rangeMax: v.rangeMax, numOf1SWalkedBy: numOf1SWalkedBy, reference: newReference))
        if v.rangeMax == "S" {
            newReference.append([])
        }
        let a = transformSchemaEntityTreeToList(
            schemaItemId: k,
            userDTO: userDTO,
            transformationId: transformationId,
            indentation: indentation+1, 
            numOf1SWalkedBy: v.rangeMax == "S" ? numOf1SWalkedBy + 1 : numOf1SWalkedBy, 
            reference: newReference
        )
        ret += a
    }
    return ret
}
