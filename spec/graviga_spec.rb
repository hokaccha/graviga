require 'spec_helper'
require 'fixtures/blog_schema';

describe Graviga do
  it 'has a version number' do
    expect(Graviga::VERSION).not_to be nil
  end

  specify do
    result = BlogSchema.execute('query name { post { id, title } }')
    expect(result).to be_a Hash
    data = result['data']
    post = data['post']
    expect(post['id']).to eq '1'
    expect(post['title']).to eq 'foo'
  end
end
