import Foundation
import Compression

final class Coder {
    func code(_ session: Session) -> Data {
        var result = Data()
        result.add(session.rating)
        result += code(session.global)
        return result
    }
    
    func code(_ global: Session.Global) -> Data {
        var result = Data()
        result.add(global.counter)
        result.append(contentsOf: global.items.flatMap(code))
        return result
    }
    
    func session(_ data: Data) -> Session {
        var data = data
        let result = Session()
        result.rating = data.date()
        result.global = global(data)
        return result
    }
    
    func global(_ data: Data) -> Session.Global {
        var data = data
        var result = Session.Global()
        result.counter = data.byte()
        while !data.isEmpty {
            result.items.append(item(&data))
        }
        return result
    }
    
    private func code(_ item: Session.Item) -> Data {
        var result = Data()
        result.add(item.id)
        result.add(item.mode)
        result.add(item.time)
        return result
    }
    
    private func item(_ data: inout Data) -> Session.Item {
        var result = Session.Item()
        result.id = data.byte()
        result.mode = data.mode()
        result.time = data.date()
        return result
    }
    
    private func code(_ data: Data) -> Data {
        data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let result = Data(bytes: buffer, count: compression_encode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZMA))
            buffer.deallocate()
            print("size: \(result.count); gain: \(data.count - result.count)")
            return result
        }
    }

    private func decode(_ data: Data) -> Data {
        data.withUnsafeBytes {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: data.count * 10)
            let read = compression_decode_buffer(buffer, data.count * 10, $0.bindMemory(to: UInt8.self).baseAddress!, data.count, nil, COMPRESSION_LZMA)
            let result = Data(bytes: buffer, count: read)
            buffer.deallocate()
            return result
        }
    }
}
