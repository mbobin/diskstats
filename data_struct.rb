class DataStruct < Dry::Struct
  transform_keys(&:to_sym)

  attribute :major_number,                    Types::Coercible::Integer
  attribute :minor_number,                    Types::Coercible::Integer
  attribute :device_name,                     Types::Coercible::String
  attribute :reads_completed_successfully,    Types::Coercible::Integer
  attribute :reads_merged,                    Types::Coercible::Integer
  attribute :sectors_read,                    Types::Coercible::Integer
  attribute :time_spent_reading,              Types::Coercible::Integer
  attribute :writes_completed,                Types::Coercible::Integer
  attribute :writes_merged,                   Types::Coercible::Integer
  attribute :sectors_written,                 Types::Coercible::Integer
  attribute :time_spent_writing,              Types::Coercible::Integer
  attribute :IOs_currently_in_progress,       Types::Coercible::Integer
  attribute :time_spent_doing_IOs,            Types::Coercible::Integer
  attribute :weighted_time_spent_doing_IOs,   Types::Coercible::Integer
  attribute :discards_completed_successfully, Types::Coercible::Integer.optional
  attribute :discards_merged,                 Types::Coercible::Integer.optional
  attribute :sectors_discarded,               Types::Coercible::Integer.optional
  attribute :time_spent_discarding,           Types::Coercible::Integer.optional
  attribute :created_at,                      Types::DateTime

  class << self
    def build_from_line(data)
      new diskstats_attributes.zip(data).to_h.merge(created_at: Time.now.utc)
    end

    def build_for_store(data)
      build_from_line(data).serialize
    end

    def diskstats_attributes
      @diskstats_attributes ||= (attribute_names - [:created_at]).freeze
    end

    def deserialize(data)
      new(attribute_names.zip(data).to_h)
    end
  end

  def serialize
    to_h.values
  end
end
