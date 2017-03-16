module ResolvHelpers
  def stub_resolv(name, address)
    dns = double(:dns)
    allow(::Resolv::DNS).to receive(:new).and_return(dns)
    allow(dns).to receive(:each_address).
      with(name).and_yield(Resolv::IPv4.create(address))
  end

  def stub_resp(host, addr, resp)
    stub_resolv(host, addr)
    allow(Net::HTTP).to receive(:get_response).and_return(resp)
  end
end

RSpec.configure do |conf|
  conf.include(ResolvHelpers)

  conf.after do
    ::Resolv::DefaultResolver.replace_resolvers([])
  end
end
