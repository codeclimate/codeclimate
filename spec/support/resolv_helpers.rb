module ResolvHelpers
  def stub_resolv(name, address)
    dns = double
    allow(::Resolv::DNS).to receive(:new).and_return(dns)
    allow(dns).to receive(:each_address).
      with(name).and_yield(Resolv::IPv4.create(address))
  end
end

RSpec.configure do |conf|
  conf.include(ResolvHelpers)
end
