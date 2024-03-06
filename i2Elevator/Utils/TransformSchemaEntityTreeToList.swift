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
    indentation: Int
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
        ret.append(IndentedSchemaItem(indentation: indentation, type: child.children.count > 0 ? "node" : "leaf", schemaItemId: k, rangeMax: v.rangeMax))
        let a = transformSchemaEntityTreeToList(
            schemaItemId: k,
            userDTO: userDTO,
            transformationId: transformationId,
            indentation: indentation+1
        )
        ret += a
    }
    return ret
}
