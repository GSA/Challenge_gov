include ErlPort::ErlTerm # rubocop:disable Style/MixinUsage
include ErlPort::Erlang # rubocop:disable Style/MixinUsage

def setup_param_decoder
  set_decoder { |v| param_decoder(v) }
  :ok
end

# Encode incoming params
# In particular, this encodes a nested Elixir keyword list into a nested hash
def param_decoder(value)
  if value.is_a?(Array) && value[0].is_a?(Tuple)
    # An Elixir keyword list comes in to Ruby as an array of ErlTerm::Tuples {key, value}
    # If first element is a ErlTerm::Tuple, assume the rest are also ErlTerm::Tuples
    # Convert this array of Tuples into a Ruby Hash (calling param_decoder recursively on each value)
    Hash[*value.flat_map { |tuple| [tuple[0], param_decoder(tuple[1])] }]
  elsif value.is_a?(Array)
    value.map { |el| param_decoder(el) }
  else
    value
  end
end

def for_testing(value)
  value.inspect
end
