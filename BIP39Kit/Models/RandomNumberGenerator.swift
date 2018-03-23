//
//  RandomNumberGenerator.swift
//  BIP39Kit
//
//  Created by Elliott Minns on 23/03/2018.
//  Copyright © 2018 Elliott Minns. All rights reserved.
//

import Foundation

protocol RandomNumberGenerator {
  static func generate(length: Int) -> Data?
}

struct SecureRandomNumberGenerator: RandomNumberGenerator {
  static func generate(length: Int) -> Data? {
    var data = Data(capacity: length)
    let result = SecRandomCopyBytes(kSecRandomDefault, length, &data)
    if (result == 0) {
      return data
    } else {
      return nil
    }
  }
}
