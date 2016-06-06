require 'test_helper'

module DomainNeutral

  class TestSymbolizedClassSuper
    class << self
      def options
        @options ||= {}
      end
      def reset_options
        @options = {}
      end
      def after_save(*args)
        options[:after_save] = args
      end

      def where(*args)
        options[:where] = *args
        []
      end
      def find(id)
        options[:find] = id
      end
      
    end
    
    def initialize(attributes = {})
      @attributes = attributes
    end
    def attributes
      @attributes ||= {}
    end
    def read_attribute(name)
      attributes[name]
    end
    def write_attribute(name, value)
      attributes[name] = value
    end
    
  end

  class TestSymbolizedClassBase < TestSymbolizedClassSuper
    include SymbolizedClass
  end
    
  class SymbolizedClassTest < ActiveSupport::TestCase
    setup do
      @tc = TestSymbolizedClassBase
    end
    context 'symbolized' do
      context 'class' do
        should 'have caching options set' do
          assert_equal [:flush_cache, {:if=>:caching_enabled}], @tc.options[:after_save]
        end
        should 'have [] accessor delegating to find_by_symbol' do
          @tc.expects(:find_by_symbol).with(:expert).returns(:ok)
          assert_equal :ok, @tc[:expert]
        end
        should 'define accessor for symbol' do
          assert !@tc.method_defined?( :expert)
          @tc.expects(:find_by_symbol).with(:expert).returns(:ok)
          assert_equal :ok, @tc.expert
          assert @tc.method_defined?( :expert)
        end
        should 'support collection' do
          @admin = @tc.new(symbol: :admin)
          @site_admin = @tc.new(symbol: :site_admin)
          @user_admin = @tc.new(symbol: :user_admin)
          @tc.expects(:find_by_symbol).with(:admin).returns(@admin)
          @tc.expects(:find_by_symbol).with(:site_admin).returns(@site_admin)
          @tc.expects(:find_by_symbol).with(:user_admin).returns(@user_admin)
          assert_equal [@admin, @site_admin, @user_admin], @tc.collection(:admin, :site_admin, :user_admin)
        end
      end
      
      context 'without cache' do
        setup do
          @tc.enable_caching false
        end
        should 'delegate find to super' do
          expect_nothing_cached do
            assert_equal 44, @tc.find(44)
            assert_equal 44, @tc.options[:find]
          end
        end
        should 'lookup object by symbol' do
          expect_nothing_cached do
            @tc.find_by_symbol :expert
            assert_equal [{symbol: :expert}], @tc.options[:where]
          end
        end
        
        context 'cache' do
          setup do
            @tc.enable_caching # true
          end
          should 'delegate find to super' do
            expect_cached [@tc.name, 44]  do
              assert_equal 44, @tc.find(44)
            end
          end
          should 'lookup object by symbol' do
            expect_cached [@tc.name, :expert] do
              @tc.expects(:where).with(symbol: :expert).returns([:ok])
              assert_equal :ok, @tc.find_by_symbol( :expert)
            end
          end
        end
      end
      
      context 'instance' do
        setup do
          @instance = @tc.new
        end
        should 'have symbol writer' do
          @instance.expects(:write_attribute).with(:symbol, 'expert').returns 'expert'
          @instance.symbol = :expert
        end
        should 'have symbol reader' do
          @instance.expects(:read_attribute).with(:symbol).once.returns 'expert'
          assert_equal :expert, @instance.symbol
          assert_equal :expert, @instance.symbol
        end
        should 'have to_sym method' do
          @instance.expects(:read_attribute).with(:symbol).once.returns 'expert'
          assert_equal :expert, @instance.to_sym
        end
        should 'generate query accessor' do
          admin = @tc.new(symbol: :admin)
          system_admin = @tc.new(symbol: :system_admin)
          @tc.expects(:find_by_symbol).with('system_admin').returns(system_admin)
          assert !admin.system_admin?
          @tc.expects(:find_by_symbol).with('admin').returns(admin)
          assert admin.admin?
        end
        context 'Comparing' do
          setup do
            @admin = @tc.new(symbol: :admin)
          end
          should 'respond to is_one_of?' do
            assert @admin.is_one_of?(:admin, :site_admin)
            assert !@admin.is_one_of?(:site_admin, :user_admin)
            assert @admin.is_one_of?([:admin, :site_admin])
            assert !@admin.is_one_of?([:site_admin, :user_admin])
            assert @admin.is_one_of?(:admin)
            assert !@admin.is_one_of?(:site_admin)
          end
          should 'respond to is_none_of?' do
            assert @admin.is_none_of?(:site_admin, :user_admin)
            assert !@admin.is_none_of?(:admin, :site_admin)
            assert @admin.is_none_of?([:site_admin, :user_admin])
            assert !@admin.is_none_of?([:admin, :site_admin])
            assert @admin.is_none_of?(:site_admin)
            assert !@admin.is_none_of?(:admin)
          end
        end
      end
      
    end
    
  end
end