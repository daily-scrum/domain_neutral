require 'test_helper'

class Bull < DomainNeutral::Descriptor
  has_many :children, as: :parent, class_name: 'Bull'
end

module DomainNeutral
  class DescriptorTest < ActiveSupport::TestCase
    context 'descriptor validation' do
      setup do
        @bull = Bull.new
      end
      subject { @bull }
    
      should validate_presence_of( :name)
      should validate_presence_of( :symbol)
      should validate_uniqueness_of(:symbol).scoped_to :type
    end  
  
    context 'relationship' do
      setup do 
        @cow = Bull.create(:symbol => :cow, :name => 'Cow')
        @calf = Bull.create(:parent => @cow, :symbol => :calf, :name => 'Calf')
      end
    
      should 'expose parent' do
        assert_equal @cow, @calf.parent
      end
    
      should 'expose children' do
        assert_equal 1, @cow.children.size
        assert_equal @calf, @cow.children.first
      end
    
      should 'return hash for to_heading' do
        assert_equal ({:cow => 'Cow'}), @cow.to_heading
      end
    
    end
  
    context 'compareable' do
      setup do
        @a = Bull.new(:index => 1)
        @b = Bull.new(:index => 2)
      end
      should 'compare equals on index' do
        assert_equal @a,@a
      end
      should 'compare greater on index' do
        assert @a < @b
      end
      should 'compare lower on index' do
        assert !(@a > @b)
      end
    end
  
    context 'reference as id' do
      should 'support typecast to integer' do
        @shit = Bull.new
        @shit.expects(:id).returns(5)
        assert_equal 5, @shit.to_i
      end
    end
    
    context 'class methods' do
      should 'include symbols' do
        assert_equal [:site_admin, :user_admin], Role.symbols.sort
      end
    end
  
    context 'translation' do
      setup do
        @current_locale = I18n.locale
      end
      teardown do
        I18n.locale = @current_locale
      end
      context 'defined' do
        should 'work depending on current locale' do
          I18n.locale = :nb
          @descriptor = Role[:user_admin]
          assert_equal 'Bruker-administrator', @descriptor.name
          assert_equal 'Kan administrere brukere....', @descriptor.description
          I18n.locale = :en
          @descriptor = Role[:user_admin]
          assert_equal 'User Administrator', @descriptor.name
          assert_equal 'Administers users and legal entities', @descriptor.description
        end
      end
      context 'undefined' do
        setup do
          @descriptor = Bull.new symbol: :shit, name: 'Dagros', description: 'Ferdinand'
        end
        should 'fall back to entity properties itself' do
          assert_equal 'Dagros', @descriptor.name
          assert_equal 'Ferdinand', @descriptor.description
        end
      end
    end
    fixtures :users
    context 'association' do
      setup do
        @user = users(:one)
      end
      should 'override reader with find' do
        Role.expects(:find).with(@user.role_id)
        @user.role
      end
      should 'not try to find record when foreign key is nil' do
        @user.role_id = nil
        Role.expects(:find).never
        @user.role
      end
    end
  end
end
