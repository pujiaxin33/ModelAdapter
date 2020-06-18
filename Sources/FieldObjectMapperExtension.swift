//
//  FieldObjectMapperExtension.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import ObjectMapper

extension Field {
    func configMapperClosure<Convertor: TransformType>(codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.convertorClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor is NilTransform<Value>) {
                if key == "birthday_coding" {
                    print("213")
                }
                self.wrappedValue <- (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
                self.wrappedValue <- map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil]
            }
        }
        self.immutableConvertorClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor is NilTransform<Value>) {
                self.wrappedValue >>> (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
                self.wrappedValue >>> map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil]
            }
        }
    }

    func configMapperOptionalClosure<Convertor: TransformType>(codingParams: CodingParams<Convertor>?) where Convertor.Object? == Value {
        self.convertorClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor.transformToJSON(nil) is NilJSON) {
                self.wrappedValue <- (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
                if key == "birthday_coding" {
                    print("213")
                }
                self.wrappedValue <- map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil]
            }
        }
        self.immutableConvertorClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor.transformToJSON(nil) is NilJSON) {
                self.wrappedValue >>> (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
                self.wrappedValue >>> map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil]
            }
        }
    }
}
