# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe User do
  before(:each) do
    @attr = {:name=> "Joao bobo", :email=> "jaobobo@email.com"}
  end

  it "should create a new instace given valid attributes" do
    User.create!(@attr)
  end

  it "should require a name" do
    no_name_user = User.new(@attr.merge(:name=> ""))
    no_name_user.should_not be_valid
  end

  it "should require a email" do
    no_email_user = User.new(@attr.merge(:email=> ""))
    no_email_user.should_not be_valid
  end

  it "sould reject names that is too long" do
    long_name= "a" *51
    long_name_user= User.new(@attr.merge(:name=> long_name))
    long_name_user.should_not be_valid
  end

  it "should accept valid email" do
    adresses= %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jpg]

    adresses.each do |adress|
      valid_email_user= User.new(@attr.merge(:email=> adress))
      valid_email_user.should be_valid
    end
  end

  it "should reject invalid email" do
    invalid_adresses= %w[user@foo,com user_at_foo.org example.user@foo.]
    invalid_adresses.each do |invalid_adress|
      invalid_email_user= User.new(@attr.merge(:email=> invalid_adress))
      invalid_email_user.should_not be_valid
    end
  end

  it "should reject duplicate email adress" do
    User.create!(@attr)
    user_with_duplicate_email= User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end

  it "should reject email identical up to case" do
    upcased_email= @attr[:email].upcase
    User.create!(@attr.merge(:email=> upcased_email))
    user_with_duplicate_email= User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
end
