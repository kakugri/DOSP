use "collections"

actor Main
  let n: U64
  let k: U64
  let worker_pool: Array[Worker] = Array[Worker].create()

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

    var work_per_worker: U64 = F64(U64(n).f64().sqrt()).u64()
    // var work_per_worker: U64 = n
    let worker_count: U64 = F64((U64(n).f64() / U64(work_per_worker).f64()).ceil()).u64()
    // let worker_count: U64 = 1


    for i in Range[U64](0, worker_count) do
      worker_pool.push(Worker(i))
    end
    for i in Range[U64](0, worker_count) do
      let worker = try worker_pool(U64(i).usize() %% U64(worker_count).usize())? else Worker(0) end
      let start: U64 = (i * work_per_worker) + 1
      let finish: U64 = if (start + work_per_worker) > n then n + 1 else start + work_per_worker end
      worker.calculate(start, finish, k, env)
    end

actor Worker
  let name: U64
  new create(name': U64) =>
    name = name'

  be calculate(start: U64, finish: U64, k: U64, env: Env) =>
    var temp: U64 = 0
    var string_answer:Array[Stringable] = Array[Stringable].create()

    string_answer.push("[")
    for j in Range[U64](start, start + k) do
      temp = temp + (j * j)
      string_answer.push(U64(j).u8().string())
    end
    string_answer.push("]")
    let epsilon: F64 = 1e-9
    for j in Range[U64](start, finish) do
        var sqroot: F64 = U64(temp).f64().sqrt()
        var sqroot_ceil: F64 = sqroot.ceil()
        var int_version: F64 = U64(F64(sqroot).u64()).f64()
        if (sqroot - sqroot_ceil) == 0  then
            env.out.print(" ".join(string_answer.values()))
        end
        temp = temp - (j * j)
        temp = temp + ((j + k) * (j + k))
        try string_answer.pop()? else temp * 1 end
        string_answer.push(k + j)
        string_answer.push("]")
        try string_answer.shift()? else temp * 1 end
        try string_answer.shift()? else temp * 1 end
        string_answer.unshift("[")
    end