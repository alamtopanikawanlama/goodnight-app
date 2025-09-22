RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Allow running a specific subset of tests
  config.filter_run_when_matching :focus

  # Disable RSpec exposing methods globally on Module and main
  config.disable_monkey_patching!

  # Use random order for tests
  config.order = :random
  Kernel.srand config.seed

  # Print the 10 slowest examples and example groups
  if ENV['RSPEC_PROFILE']
    config.profile_examples = 10
  end
end

def freeze_time(&block)
  time = Time.current
  allow(Time).to receive(:current).and_return(time)
  block.call
ensure
  allow(Time).to receive(:current).and_call_original
end
