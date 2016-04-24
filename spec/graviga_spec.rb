require 'spec_helper'
require 'fixtures/blog_schema';

describe Graviga do
  it 'has a version number' do
    expect(Graviga::VERSION).not_to be nil
  end
end
