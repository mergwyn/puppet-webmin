require 'spec_helper'
describe 'webmin::params', :type => :class do

  it "Should not contain any resources" do
    expect(subject.call.resources.size).to eq(4)
  end
end
