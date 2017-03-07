require "spec_helper"

describe CC::CLI::FileStore do
  def test_file_class(file_name)
    Class.new(described_class).tap do |c|
      c.const_set :FILE_NAME, file_name
      c.send :public, :data
    end
  end

  def write_test_file(content, fn = file_name)
    File.write(fn, content)
  end

  let(:dir) { Dir.mktmpdir }
  let(:file_name) { File.join dir, "idk.yml" }
  after(:each) do
    FileUtils.remove_entry dir
  end

  it "loads data on instantiation" do
    write_test_file("---\ntest: instantiation")

    test_file = test_file_class(file_name).new

    expect(test_file.data).to eq("test" => "instantiation")
  end

  it "doesn't fail when there's no file" do
    expect do
      test_file_class(file_name).new
    end.to_not raise_error
  end

  it "has empty data when there's no file" do
    test_file = test_file_class(file_name).new

    expect(test_file.data).to eq({})
  end

  it "doesn't saves data to a non-existent file" do
    test_file = test_file_class(file_name).new
    expect(test_file.save).to eq false

    expect(File.exist?(file_name)).to eq false
  end

  it "saves data to the file" do
    FileUtils.touch file_name
    test_file = test_file_class(file_name).new
    test_file.data["test"] = "save"
    expect(test_file.save).to eq true

    expect(File.exist?(file_name)).to eq true
    expect(File.read(file_name)).to eq "---\ntest: save\n"
  end
end
