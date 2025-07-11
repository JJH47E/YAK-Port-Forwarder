//
//  Cloneable.swift
//  YAK Port Forwarder
//
//  Created by JJ Hayter on 11/07/2025.
//

import Foundation

protocol Cloneable<TCloneable> {
    associatedtype TCloneable
    func clone() -> TCloneable
}
