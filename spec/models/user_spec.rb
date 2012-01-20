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
    @attr = {
        :name=> "Joao bobo",
        :email=> "jaobobo@email.com",
        :password=> '123456',
        :password_confirmation=> '123456'
    }
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

  describe "password validation" do
    it "should require a password" do
      user_without_password= User.new(@attr.merge(:password=> '', :password_confirmation=> ''))
      user_without_password.should_not be_valid
    end

    it "should require a matching password confirmation" do
      user_with_different_confirmationpassword= User.new(@attr.merge(:password_confirmation=> 'different'))
      user_with_different_confirmationpassword.should_not be_valid
    end

    it "should reject short password" do
      short= "a" *5
      invalid_attrs= @attr.merge(:password=> short, :password_confirmation=> short)
      user_with_short_password= User.new(invalid_attrs)
      user_with_short_password.should_not be_valid
    end

    it "should reject long password" do
      long= "a" *41
      invalid_attrs= @attr.merge(:password=> long, :password_confirmation=> long)
      user_with_long_password= User.new(invalid_attrs)
      user_with_long_password.should_not be_valid
    end
  end

  describe "password encryption" do
    before(:each) do
      @user= User.create!(@attr)
    end

    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end

    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end

    describe "has_password? method" do
      it "should be true if the passwords match" do
        @user.has_password?(@attr[:password]).should be_true
      end

      it "should be false if the passwords don't match" do
        @user.has_password?('invalid').should be_false
      end
    end

    describe "authenticated method" do
      it "should return nil on email/password mismatch" do
        wrong_password_user= User.authenticate(@attr[:email], 'wrongpass')
        wrong_password_user.should be_nil
      end

      it "should return nil for an email address with no user" do
        nonexistent_user= User.authenticate("vish@email.com", @attr[:password])
        nonexistent_user.should be_nil
      end

      it "should return the user on email/password match" do
        matching_user= User.authenticate(@attr[:email], @attr[:password])
        matching_user.should == @user
      end
    end
  end

  describe "admin attribute" do
    before(:each) do
      @user= User.create!(@attr)
    end

    it "should respond to admin" do
      @user.should respond_to(:admin)
    end

    it "should not be an admin by default" do
      @user.should_not be_admin
    end

    it "should be convertible to an admin" do
      @user.toggle!(:admin)
      @user.should be_admin
    end
  end
end
