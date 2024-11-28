//
//  UserdefaultKey.swift
//  Reforest
//
//  Created by 가은리 on 11/29/24.
//

import SwiftUI

enum UserDefaultKey: String, CaseIterable {
    
    case meCategoryModelList
    case profile
    
    static func saveObjectInDevice<T: Encodable>(key: UserDefaultKey, content: T) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(content) {
            print(key.rawValue + "가 저장됨")
            UserDefaults.standard.setValue(encoded, forKey: key.rawValue)
        }
    }
    
    static func getObjectFromDevice<T:Decodable>(key: UserDefaultKey, _ type: T.Type) -> T? {
        if let object = UserDefaults.standard.object(forKey: key.rawValue) as? Data {
            return try? JSONDecoder().decode(T.self, from: object)
        } else {
            return nil
        }
    }
}
