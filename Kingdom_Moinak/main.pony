use "collections"

actor Main
  let n: U64
  let k: U64
  let worker_array: Array[Worker] = Array[Worker].create()

  new create(env: Env) =>
    if env.args.size() < 3 then
      env.out.print("Usage: ./lukas <n> <k>")
      n = 40
      k = 24
      return
    end

    // Parse n and k from command-line arguments
    n = try env.args(1)?.u64()? else 40 end
    k = try env.args(2)?.u64()? else 24 end

    //scale work to be done by each worker with square root function
    var work_per_worker: U64 = F64(U64(n).f64().pow(0.5)).u64()
    //Find the number of workers
    let worker_count: U64 = F64((U64(n).f64() / U64(work_per_worker).f64()).ceil()).u64()

    //Create the requirewd workers
    for index in Range[U64](0, worker_count) do
      worker_array.push(Worker(index))
    end

    //Assign work to the workers
    for index in Range[U64](0, worker_count) do
      let worker = try worker_array(U64(index).usize() % U64(worker_count).usize())? else Worker(0) end
      let first: U64 = (index * work_per_worker) + 1
      let last: U64 = if (first + work_per_worker) > n then n + 1 else first + work_per_worker end
      worker.calculate_sums(first, last, k, env)
    end

actor Worker
  let index: U64
  new create(index': U64) =>
    index = index'

  be calculate_sums(first: U64, last: U64, k: U64, env: Env) =>
    var squared_sum: U64 = 0
    var potential_answer:Array[Stringable] = Array[Stringable].create()

    potential_answer.push("[")
    for number in Range[U64](first, first + k) do
      squared_sum = squared_sum + (number * number)
      potential_answer.push(U64(number).string())
      //Early stop for when squared sum is greater the max F64 number
      if squared_sum > 9218868437227405311 then
        return
      end
    end
    potential_answer.push("]")
    for number in Range[U64](first, last) do
        var square_root: F64 = U64(squared_sum).f64().sqrt()
        var square_root_ceil: F64 = square_root.ceil()
        if (square_root - square_root_ceil) == 0  then
            env.out.print(" ".join(potential_answer.values()))
        end
        squared_sum = squared_sum - (number * number)
        squared_sum = squared_sum + ((number + k) * (number + k))
        try potential_answer.pop()? else number end
        potential_answer.push(k + number)
        potential_answer.push("]")
        try potential_answer.shift()? else number end
        try potential_answer.shift()? else number end
        potential_answer.unshift("[")
        //Early stop for when squared sum is greater the max F64 number
        if squared_sum > 9218868437227405311 then
            return
        end
    end