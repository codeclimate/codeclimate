require "spec_helper"

RSpec.describe CC::CLI::XDGFile do
  def test_file_class(xdg_home, xdg_env_var, namespace, file_name)
    Class.new(described_class).tap do |c|
      c.const_set :XDG_HOME, xdg_home
      c.const_set :XDG_ENV_VAR, xdg_env_var
      c.const_set :NAMESPACE, namespace
      c.const_set :FILE_NAME, file_name
      c.send :public, :data
    end
  end

  def write_test_file(content, d = dir, ns = namespace, fn = file_name)
    Dir.mkdir File.join(d, ns)
    File.write(File.join(d, ns, fn), content)
  end

  let(:dir) { Dir.mktmpdir }
  let(:alt_dir) { Dir.mktmpdir }
  let(:namespace) { "testns" }
  let(:file_name) { "idk.yml" }
  after(:each) do
    FileUtils.remove_entry dir
    FileUtils.remove_entry alt_dir
  end

  it "loads data on instantiation" do
    write_test_file("---\ntest: instantiation")

    test_file = test_file_class(dir, "RANDOM_TEST_HOME", namespace, file_name).new

    expect(test_file.data).to eq("test" => "instantiation")
  end

  it "doesn't fail when there's no file" do
    expect do
      test_file_class(dir, "RANDOM_TEST_HOME", namespace, file_name).new
    end.to_not raise_error
  end

  it "has empty data when there's no file" do
    test_file = test_file_class(dir, "RANDOM_TEST_HOME", namespace, file_name).new

    expect(test_file.data).to eq({})
  end

  it "looks for the file inside of XDG_HOME const" do
    write_test_file("---\ntest: xdg home")

    test_file = test_file_class(dir, "RANDOM_TEST_HOME", namespace, file_name).new

    expect(test_file.data).to eq("test" => "xdg home")
  end

  it "looks for the file inside of env var specified in XDG_ENV_VAR const" do
    write_test_file("---\ntest: env var", alt_dir)

    ENV["RANDOM_TEST_HOME"] = alt_dir
    test_file = test_file_class(dir, "RANDOM_TEST_HOME", namespace, file_name).new
    ENV.delete "RANDOM_TEST_HOME"

    expect(test_file.data).to eq("test" => "env var")
  end

  it "saves data to the file" do
    test_file = test_file_class(dir, "RANDOM_TEST_HOME", namespace, file_name).new
    test_file.data["test"] = "save"
    expect(test_file.save).to eq true

    saved_file_name = File.join(dir, namespace, file_name)

    expect(File.exist?(saved_file_name)).to eq true
    expect(File.read(saved_file_name)).to eq "---\ntest: save\n"
  end
end
