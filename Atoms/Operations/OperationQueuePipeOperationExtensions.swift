import Foundation

extension OperationQueue {
    
    public func runUniformPipeline<T>(operations: [PipeOperation<T,T>]) {
        guard let first = operations.first else { return }
        runUniformPipeline(first: first, rest: Array(operations[1..<operations.count]))
    }
    
    private func runUniformPipeline<T>(first first: PipeOperation<T,T>, rest: [PipeOperation<T,T>]) {
        guard let second = rest.first else {
            addOperation(first)
            return
        }
        let series = first |> second
        let remainingOperations = Array(rest[1..<rest.count])
        runUniformPipeline(series: series, rest: remainingOperations)
    }
    
    private func runUniformPipeline<T>(series series: PipeSeries<T,T,T,T>, rest: [PipeOperation<T,T>]) {
        guard let next = rest.first else {
            addOperations(series.operations, waitUntilFinished: false)
            return
        }
        let newSeries = series |> next
        let remainingOperations = Array(rest[1..<rest.count])
        runUniformPipeline(series: newSeries, rest: remainingOperations)
    }
}
