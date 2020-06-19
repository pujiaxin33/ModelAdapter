//
//  FieldObjectMapperExtension.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import ObjectMapper

extension Field {
    func configMapperClosure() {
        self.convertorClosure = {[weak self] (key, map) in
            guard let self = self else { return }
            self.wrappedValue <- map[key]
        }
        self.immutableConvertorClosure = {[weak self] (key, map) in
            guard let self = self else { return }
             self.wrappedValue >>> map[key]
        }
    }

    func configMapperConvertorClosure<Convertor: TransformType>(codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.convertorClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor is NilTransform<Value>) {
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

    func configMapperOptionalClosure() {
        self.convertorClosure = {[weak self] (key, map) in
            guard let self = self else { return }
            self.wrappedValue <- map[key]
        }
        self.immutableConvertorClosure = {[weak self] (key, map) in
            guard let self = self else { return }
             self.wrappedValue >>> map[key]
        }
    }

    func configMapperOptionalConvertorClosure<Convertor: TransformType>(codingParams: CodingParams<Convertor>?) where Convertor.Object? == Value {
        self.convertorClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor.transformToJSON(nil) is NilJSON) {
                self.wrappedValue <- (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
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
