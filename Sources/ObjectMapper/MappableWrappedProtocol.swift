//
//  FieldObjectMapperExtension.swift
//  ModelAdaptor
//
//  Created by jiaxin on 2020/6/15.
//

import Foundation
import ObjectMapper

extension Field: FieldMappableWrappedProtocol { }
extension Field: BaseMappableValueWrappedProtocol where Value: BaseMappable {
    public func configBaseMappableMapperClosure() {
        self.mapperClosure = {[weak self] (key, map) in
            guard let self = self else { return }
            self.wrappedValue <- map[key]
        }
        self.immutableMapperClosure = {[weak self] (key, map) in
            guard let self = self else { return }
             self.wrappedValue >>> map[key]
        }
    }
}

extension Field {
    func configMapperClosure() {
        self.mapperClosure = {[weak self] (key, map) in
            guard let self = self else { return }
            self.wrappedValue <- map[key]
        }
        self.immutableMapperClosure = {[weak self] (key, map) in
            guard let self = self else { return }
             self.wrappedValue >>> map[key]
        }
    }

    func configMapperConvertorClosure<Convertor: TransformType>(codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.mapperClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor is NilTransform<Value>) {
                self.wrappedValue <- (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
                self.wrappedValue <- map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil]
            }
        }
        self.immutableMapperClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor is NilTransform<Value>) {
                self.wrappedValue >>> (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
                self.wrappedValue >>> map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil]
            }
        }
    }
}

extension FieldOptional: FieldOptionalMappableWrappedProtocol {}
extension FieldOptional: BaseMappableValueWrappedProtocol where Value: BaseMappable {
    public func configBaseMappableMapperClosure() {
        self.mapperClosure = {[weak self] (key, map) in
            guard let self = self else { return }
            self.wrappedValue <- map[key]
        }
        self.immutableMapperClosure = {[weak self] (key, map) in
            guard let self = self else { return }
             self.wrappedValue >>> map[key]
        }
    }
}

extension FieldOptional {
    func configMapperClosure() {
        self.mapperClosure = {[weak self] (key, map) in
            guard let self = self else { return }
            self.wrappedValue <- map[key]
        }
        self.immutableMapperClosure = {[weak self] (key, map) in
            guard let self = self else { return }
             self.wrappedValue >>> map[key]
        }
    }

    func configMapperConvertorClosure<Convertor: TransformType>(codingParams: CodingParams<Convertor>?) where Convertor.Object == Value {
        self.mapperClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor is NilTransform<Value>) {
                self.wrappedValue <- (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
                self.wrappedValue <- map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil]
            }
        }
        self.immutableMapperClosure = {[weak self] (key, map) in
            guard let self = self, let codingParams = codingParams else { return }
            if let convertor = codingParams.convertor, !(convertor is NilTransform<Value>) {
                self.wrappedValue >>> (map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil], convertor)
            }else {
                self.wrappedValue >>> map[key, nested: codingParams.nested, delimiter: codingParams.delimiter, ignoreNil: codingParams.ignoreNil]
            }
        }
    }
}
