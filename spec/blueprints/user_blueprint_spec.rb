require "rails_helper"

RSpec.describe UserBlueprint, type: :blueprint do
  let(:user_attributes) { attributes_for(:user, id: 1000) }
  let(:user) do
    build(
      :user,
      id:    user_attributes[:id],
      email: user_attributes[:email],
      role:  user_attributes[:role]
    )
  end

  describe ".render_as_hash" do
    subject(:hash) { UserBlueprint.render_as_hash(user) }

    it "includes the identifier :id" do
      expect(hash).to include(id: 1000)
    end

    it "includes the email field" do
      expect(hash).to include(email: user_attributes[:email])
    end

    it "includes the role field" do
      expect(hash).to include(role: user_attributes[:role].to_s)
    end

    it "does not include unexpected attributes" do
      allowed_keys = [ :id, :email, :role ]
      expect(hash.keys).to match_array(allowed_keys)
    end
  end

  describe ".render_as_hash on a collection" do
    let(:user2_attributes) { attributes_for(:user, id: 1001) }
    let(:user2) do
      build(
        :user,
        id:    user2_attributes[:id],
        email: user2_attributes[:email],
        role:  user2_attributes[:role]
      )
    end

    subject(:array) { UserBlueprint.render_as_hash([user, user2]) }

    it "returns an array of hashes" do
      expect(array).to be_an(Array)
      expect(array.size).to eq(2)
    end

    it "serializes each element correctly" do
      expect(array[0]).to include(id: user_attributes[:id], email: user_attributes[:email], role: user_attributes[:role].to_s)
      expect(array[1]).to include(id: user2_attributes[:id], email: user2_attributes[:email], role: user2_attributes[:role].to_s)
    end
  end
end
