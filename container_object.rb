require "pstore"

class ContainerObject
  extend Dry::Container::Mixin

  register(:data_file, "diskstats.store")
  register(:input_file, "/proc/diskstats")

  register(:data_store, PStore.new(resolve(:data_file)))
  register(:sequence) do
    store = resolve(:data_store)
    store[:sequence] = store[:sequence].to_i.next
  end

  register(:add_record) do |data|
    store = resolve(:data_store)
    store.transaction do
      store[resolve(:sequence)] = DataStruct.build_for_store(data)
    end
  end

  register(:perform_reading) do |file|
    File.readlines(file).each do |line|
      resolve(:add_record).call(line.split)
    end
  end

  register(:import) do
    resolve(:perform_reading).call(resolve(:input_file))
  end

  register(:size) do
    store = resolve(:data_store)
    store.transaction { store[:sequence].to_i }
  end

  register(:fetch_record) do |index|
    store = resolve(:data_store)
    data = store.transaction { store[index] }
    DataStruct.deserialize(data)
  end

  register(:each_record) do |block|
    1.upto(resolve(:size)) do |index|
      block.call resolve(:fetch_record).call(index)
    end
  end
end
